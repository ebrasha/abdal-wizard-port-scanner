{
  * Created by Abdal Security Group.
  * Programmer: Ebrahim Shafiei  (EbraSha)
  * Programmer WebSite: https://hackers.zone/
  * Programmer Email: Prof.Shafiei@Gmail.com
  * License : AGCL
  * Delphi: 11.0
}

unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Unit1;

type
  TForm3 = class(TForm)
    RichEdit1: TRichEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);
begin
  Form1.Show;

  Self.Hide;

end;

procedure TForm3.Button2Click(Sender: TObject);
begin
  Application.Terminate;
end;

end.
