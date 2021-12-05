{
  * Created by Abdal Security Group.
  * Programmer: Ebrahim Shafiei  (EbraSha)
  * Programmer WebSite: https://hackers.zone/
  * Programmer Email: Prof.Shafiei@Gmail.com
  * License : AGCL
  * Delphi: 11.0
}
unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, IdUDPBase, IdUDPClient,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, Vcl.StdCtrls,
  System.ImageList, Vcl.ImgList, Unit2, Vcl.Imaging.pngimage, ShellAPI,
  Vcl.ExtCtrls,
  Vcl.MPlayer, mmsystem;

type
  TForm1 = class(TForm)
    start_scan_bt: TButton;
    ProgressBar1: TProgressBar;
    ListBox_open_port: TListBox;
    ImageList_icon: TImageList;
    GroupBox1: TGroupBox;
    GroupBox3: TGroupBox;
    Label_Thread_01: TLabel;
    Edit_Thread_01_start: TEdit;
    Edit_Thread_01_end: TEdit;
    Label_Thread_01_to: TLabel;
    Label_Thread_02_to: TLabel;
    Edit_Thread_02_end: TEdit;
    Edit_Thread_02_start: TEdit;
    Label_Thread_02: TLabel;
    Label_Thread_03_to: TLabel;
    Edit_Thread_03_end: TEdit;
    Edit_Thread_03_start: TEdit;
    Label_Thread_03: TLabel;
    Edit_taget_ip: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ProgressBar3: TProgressBar;
    GroupBox4: TGroupBox;
    Edit_timeout: TEdit;
    Label5: TLabel;
    GroupBox2: TGroupBox;
    ListBox_close_port: TListBox;
    ProgressBar2: TProgressBar;
    Label_port_t1: TLabel;
    Label_port_t2: TLabel;
    Label_port_t3: TLabel;
    Button1: TButton;
    Label_Scanning_Status: TLabel;
    Button_stop_scan: TButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    procedure start_scan_btClick(Sender: TObject);
    procedure ListBox_open_portDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox_close_portDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button_stop_scanClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  var
    port_counter_scan: Integer;
  end;

{$REGION 'Init PortScan Thread 01'}

  PortScannerThread1 = class(TThread)
  protected
    procedure Execute; override;

  end;

{$ENDREGION}
{$REGION 'Init PortScan Thread 02'}

  PortScannerThread2 = class(TThread)
  protected
    procedure Execute; override;

  end;

{$ENDREGION}
{$REGION 'Init PortScan Thread 03'}

  PortScannerThread3 = class(TThread)
  protected
    procedure Execute; override;

  end;

{$ENDREGION}

var
  Form1: TForm1;

implementation

uses Unit3;
{$R *.dfm}
{$REGION 'Play Audio'}

procedure FGPlayASound(const AResName: string);
var
  HResource: TResourceHandle;
  HResData: THandle;
  PWav: Pointer;
begin
  HResource := FindResource(HInstance, PChar(AResName), RT_RCDATA);
  if HResource <> 0 then
  begin
    HResData := LoadResource(HInstance, HResource);
    if HResData <> 0 then
    begin
      PWav := LockResource(HResData);
      if Assigned(PWav) then
      begin
        // uses MMSystem
        sndPlaySound(nil, SND_NODEFAULT); // nil = stop currently playing
        sndPlaySound(PWav, SND_ASYNC or SND_MEMORY);
      end;
      // UnlockResource(HResData); // unnecessary per MSDN
      // FreeResource(HResData);   // unnecessary per MSDN
    end;
  end
  else
    RaiseLastOSError;
end;
{$ENDREGION}

procedure TForm1.start_scan_btClick(Sender: TObject);
begin

  if Edit_taget_ip.Text = '' then
  begin

    FGPlayASound('Resource_error');
    MessageDlg('target is empty, Please enter the target ip...', mtError,
      [mbOK], 0)

  end
  else
  begin

    Form1.Label_Scanning_Status.Caption := 'Scanning Status: Run';

    ListBox_close_port.Clear;
    ListBox_open_port.Clear;
{$REGION 'Start Scan th 01'}
    try

      with PortScannerThread1.Create do
        FreeOnTerminate := true;

    except
      on e: Exception do
      begin
        ShowMessage('error in Execute=' + e.Message);
        raise;
      end;
    end;
{$ENDREGION}
{$REGION 'Start Scan th 02'}
    try

      with PortScannerThread2.Create do
        FreeOnTerminate := true;

    except
      on e: Exception do
      begin
        ShowMessage('error in Execute=' + e.Message);
        raise;
      end;
    end;
{$ENDREGION}
{$REGION 'Start Scan th 03'}
    try

      with PortScannerThread3.Create do
        FreeOnTerminate := true;

    except
      on e: Exception do
      begin
        ShowMessage('error in Execute=' + e.Message);
        raise;
      end;
    end;
{$ENDREGION}
  end;

end;

{$REGION 'PortScannerThread Execution 01 '}
{ PortScannerThread }

procedure PortScannerThread1.Execute;

{$REGION 'TCP Port Scanner Func'}
  function TcpPortScanner(const APort: Integer; const AAddress: string)
    : Boolean;
  var
    LTcpClient: TIdTCPClient;
  begin
    LTcpClient := TIdTCPClient.Create(nil);
    try
      try
        LTcpClient.Host := AAddress; // which server to test
        LTcpClient.Port := APort; // which port to test
        LTcpClient.ConnectTimeout := StrToInt(Form1.Edit_timeout.Text);
        // assume a port to be clodes if it does not respond within 200ms (some ports will immediately reject, others are using a "stealth" mechnism)
        LTcpClient.Connect; // try to connect
        result := true; // port is open
      except
        result := false;
      end;
    finally
      freeAndNil(LTcpClient);
    end;
  end;
{$ENDREGION}

var
  s_port: Integer;
var
  counter: Integer;
var
  hostscan: string;
var
  progress_max: Integer;
var
  progress_min: Integer;
  // var
  // TCPClient_Scanner: TIdTCPClient;
begin
  hostscan := Form1.Edit_taget_ip.Text;
  counter := 0;
  progress_max := StrToInt(Form1.Edit_Thread_01_end.Text) -
    StrToInt(Form1.Edit_Thread_01_start.Text);
  progress_min := 0;
  Form1.ProgressBar1.Min := progress_min;
  Form1.ProgressBar1.Max := progress_max;
  for s_port := StrToInt(Form1.Edit_Thread_01_start.Text)
    to StrToInt(Form1.Edit_Thread_01_end.Text) do
  begin
    if Form1.Label_Scanning_Status.Caption = 'Scanning Status: Cancel' then
      break;

    counter := counter + 1;

    // Add couner port scan

    Form1.Label_port_t1.Caption := 'Total Scan Port: ' + IntToStr(counter - 1);

    if TcpPortScanner(s_port, hostscan) then
    begin
      // Form1.list_scan_result.Lines.Add('Port' + IntToStr(s_port) +
      // ' TCP is Open');
      Form1.ListBox_open_port.Items.Add('Port ' + IntToStr(s_port) +
        ' TCP is Open');
      // Beep();
      FGPlayASound('aud_find_port');
      // Form1.ListBox_open_port.Perform(WM_VSCROLL, SB_BOTTOM, 0);
      // Form1.ListBox_open_port.Perform(WM_VSCROLL, SB_ENDSCROLL, 0);
      Form1.ListBox_open_port.TopIndex :=
        -1 + Form1.ListBox_open_port.Items.Count;

    end
    else
    begin
      // Form1.list_scan_n_open.Lines.Add('Port ' + IntToStr(s_port) +
      // ' TCP is Close');
      Form1.ListBox_close_port.Items.Add('Port ' + IntToStr(s_port) +
        ' TCP is Close');
      // Form1.ListBox_close_port.Perform(WM_VSCROLL, SB_BOTTOM, 0);
      // Form1.ListBox_close_port.Perform(WM_VSCROLL, SB_ENDSCROLL, 0);
      Form1.ListBox_close_port.TopIndex :=
        -1 + Form1.ListBox_close_port.Items.Count;
    end;

    Form1.ProgressBar1.Position := counter;

  end;
  // Remove TCPClient_Scanner instant
  // TCPClient_Scanner.Destroy;

end;
{$ENDREGION}
{$REGION 'PortScannerThread Execution 02 '}
{ PortScannerThread }

procedure PortScannerThread2.Execute;

  function TcpPortScanner(const APort: Integer; const AAddress: string)
    : Boolean;
  var
    LTcpClient: TIdTCPClient;
  begin
    LTcpClient := TIdTCPClient.Create(nil);
    try
      try
        LTcpClient.Host := AAddress; // which server to test
        LTcpClient.Port := APort; // which port to test
        LTcpClient.ConnectTimeout := StrToInt(Form1.Edit_timeout.Text);
        // assume a port to be clodes if it does not respond within 200ms (some ports will immediately reject, others are using a "stealth" mechnism)
        LTcpClient.Connect; // try to connect
        result := true; // port is open
      except
        result := false;
      end;
    finally
      freeAndNil(LTcpClient);
    end;
  end;

var
  s_port: Integer;
var
  counter: Integer;
var
  hostscan: string;
var
  progress_max: Integer;
var
  progress_min: Integer;
  // var
  // TCPClient_Scanner: TIdTCPClient;
begin
  counter := 0;
  hostscan := Form1.Edit_taget_ip.Text;

  progress_max := StrToInt(Form1.Edit_Thread_02_end.Text) -
    StrToInt(Form1.Edit_Thread_02_start.Text);
  progress_min := 0;
  Form1.ProgressBar2.Min := progress_min;
  Form1.ProgressBar2.Max := progress_max;

  for s_port := StrToInt(Form1.Edit_Thread_02_start.Text)
    to StrToInt(Form1.Edit_Thread_02_end.Text) do
  begin
    if Form1.Label_Scanning_Status.Caption = 'Scanning Status: Cancel' then
      break;

    counter := counter + 1;
    // Add couner port scan

    Form1.Label_port_t2.Caption := 'Total Scan Port: ' + IntToStr(counter - 1);

    if TcpPortScanner(s_port, hostscan) then
    begin
      // Form1.list_scan_result.Lines.Add('Port' + IntToStr(s_port) +
      // ' TCP is Open');
      Form1.ListBox_open_port.Items.Add('Port ' + IntToStr(s_port) +
        ' TCP is Open');
      FGPlayASound('aud_find_port');
      // Form1.ListBox_open_port.Perform(WM_VSCROLL, SB_BOTTOM, 0);
      // Form1.ListBox_open_port.Perform(WM_VSCROLL, SB_ENDSCROLL, 0);
      Form1.ListBox_open_port.TopIndex :=
        -1 + Form1.ListBox_open_port.Items.Count;

    end
    else
    begin
      // Form1.list_scan_n_open.Lines.Add('Port ' + IntToStr(s_port) +
      // ' TCP is Close');
      Form1.ListBox_close_port.Items.Add('Port ' + IntToStr(s_port) +
        ' TCP is Close');
      // Form1.ListBox_close_port.Perform(WM_VSCROLL, SB_BOTTOM, 0);
      // Form1.ListBox_close_port.Perform(WM_VSCROLL, SB_ENDSCROLL, 0);
      Form1.ListBox_close_port.TopIndex :=
        -1 + Form1.ListBox_close_port.Items.Count;
    end;

    Form1.ProgressBar2.Position := counter;

  end;
  // Remove TCPClient_Scanner instant
  // TCPClient_Scanner.Destroy;

end;
{$ENDREGION}
{$REGION 'PortScannerThread Execution 03 '}
{ PortScannerThread }

procedure PortScannerThread3.Execute;

  function TcpPortScanner(const APort: Integer; const AAddress: string)
    : Boolean;
  var
    LTcpClient: TIdTCPClient;
  begin
    LTcpClient := TIdTCPClient.Create(nil);
    try
      try
        LTcpClient.Host := AAddress; // which server to test
        LTcpClient.Port := APort; // which port to test
        LTcpClient.ConnectTimeout := StrToInt(Form1.Edit_timeout.Text);
        // assume a port to be clodes if it does not respond within 200ms (some ports will immediately reject, others are using a "stealth" mechnism)
        LTcpClient.Connect; // try to connect
        result := true; // port is open
      except
        result := false;
      end;
    finally
      freeAndNil(LTcpClient);
    end;
  end;

var
  s_port: Integer;
var
  counter: Integer;
var
  hostscan: string;
var
  progress_max: Integer;
var
  progress_min: Integer;
  // var
  // TCPClient_Scanner: TIdTCPClient;
begin
  counter := 0;
  hostscan := Form1.Edit_taget_ip.Text;

  progress_max := StrToInt(Form1.Edit_Thread_03_end.Text) -
    StrToInt(Form1.Edit_Thread_03_start.Text);
  progress_min := 0;
  Form1.ProgressBar3.Min := progress_min;
  Form1.ProgressBar3.Max := progress_max;

  for s_port := StrToInt(Form1.Edit_Thread_03_start.Text)
    to StrToInt(Form1.Edit_Thread_03_end.Text) do
  begin
    if Form1.Label_Scanning_Status.Caption = 'Scanning Status: Cancel' then
      break;
    counter := counter + 1;
    // Add couner port scan

    Form1.Label_port_t3.Caption := 'Total Scan Port: ' + IntToStr(counter - 1);

    if TcpPortScanner(s_port, hostscan) then
    begin
      // Form1.list_scan_result.Lines.Add('Port' + IntToStr(s_port) +
      // ' TCP is Open');
      Form1.ListBox_open_port.Items.Add('Port ' + IntToStr(s_port) +
        ' TCP is Open');
      FGPlayASound('aud_find_port');
      // Form1.ListBox_open_port.Perform(WM_VSCROLL, SB_BOTTOM, 0);
      // Form1.ListBox_open_port.Perform(WM_VSCROLL, SB_ENDSCROLL, 0);
      Form1.ListBox_open_port.TopIndex :=
        -1 + Form1.ListBox_open_port.Items.Count;

    end
    else
    begin
      // Form1.list_scan_n_open.Lines.Add('Port ' + IntToStr(s_port) +
      // ' TCP is Close');
      Form1.ListBox_close_port.Items.Add('Port ' + IntToStr(s_port) +
        ' TCP is Close');
      // Form1.ListBox_close_port.Perform(WM_VSCROLL, SB_BOTTOM, 0);
      // Form1.ListBox_close_port.Perform(WM_VSCROLL, SB_ENDSCROLL, 0);
      Form1.ListBox_close_port.TopIndex :=
        -1 + Form1.ListBox_close_port.Items.Count;
    end;

    Form1.ProgressBar3.Position := counter;

  end;
  // Remove TCPClient_Scanner instant
  // TCPClient_Scanner.Destroy;

end;
{$ENDREGION}
{$REGION 'ListBox Picture'}

procedure TForm1.Button1Click(Sender: TObject);
begin
  Form3.Close;
  Application.Terminate();
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
{$REGION 'Start Scan th 03'}
  try

    with PortScannerThread3.Create do
      FreeOnTerminate := true;

  except
    on e: Exception do
    begin
      ShowMessage('error in Execute=' + e.Message);
      raise;
    end;
  end;
{$ENDREGION}
end;

procedure TForm1.Button_stop_scanClick(Sender: TObject);
begin
  FGPlayASound('Resource_stop');
  Form1.Label_Scanning_Status.Caption := 'Scanning Status: Cancel';

end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  var
    url: string;
  url := 'https://donate.abdalagency.ir/';
  ShellExecute(HInstance, 'open', PChar(url), nil, nil, SW_NORMAL);
end;

procedure TForm1.Image2Click(Sender: TObject);
begin
  var
    url: string;
  url := 'https://gitlab.com/abdal-security-group/abdal-wizard-port-scanner';
  ShellExecute(HInstance, 'open', PChar(url), nil, nil, SW_NORMAL);

end;

procedure TForm1.Image3Click(Sender: TObject);
begin
  var
    url: string;
  url := 'https://github.com/abdal-security-group/abdal-wizard-port-scanner';
  ShellExecute(HInstance, 'open', PChar(url), nil, nil, SW_NORMAL);
end;

procedure TForm1.ListBox_close_portDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LBox: TListBox;
  R: TRect;
  S: string;
  TextTopPos, TextLeftPos, TextHeight: Integer;
const
  IMAGE_TEXT_SPACE = 5;
begin
  LBox := Control as TListBox;
  R := Rect;
  LBox.Canvas.FillRect(R);
  ImageList_icon.Draw(LBox.Canvas, R.Left, R.Top, 0);
  S := LBox.Items[Index];
  TextHeight := LBox.Canvas.TextHeight(S);
  TextLeftPos := R.Left + ImageList_icon.Width + IMAGE_TEXT_SPACE;
  TextTopPos := R.Top + R.Height div 2 - TextHeight div 2;
  LBox.Canvas.TextOut(TextLeftPos, TextTopPos, S);
end;

procedure TForm1.ListBox_open_portDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  LBox: TListBox;
  R: TRect;
  S: string;
  TextTopPos, TextLeftPos, TextHeight: Integer;
const
  IMAGE_TEXT_SPACE = 5;
begin
  LBox := Control as TListBox;
  R := Rect;
  LBox.Canvas.FillRect(R);
  ImageList_icon.Draw(LBox.Canvas, R.Left, R.Top, 1);
  S := LBox.Items[Index];
  TextHeight := LBox.Canvas.TextHeight(S);
  TextLeftPos := R.Left + ImageList_icon.Width + IMAGE_TEXT_SPACE;
  TextTopPos := R.Top + R.Height div 2 - TextHeight div 2;
  LBox.Canvas.TextOut(TextLeftPos, TextTopPos, S);
end;

{$ENDREGION}

end.
