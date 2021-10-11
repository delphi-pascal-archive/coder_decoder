unit Uni;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, ActnList;

type
  TForm1 = class(TForm)
    Button1: TButton;
    LabeledEdit1: TLabeledEdit;
    Button2: TButton;
    RadioGroup1: TRadioGroup;
    OpenDialog1: TOpenDialog;
    ActionList1: TActionList;
    Coding: TAction;
    Decoding: TAction;
    LabeledEdit3: TLabeledEdit;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CodingExecute(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DecodingExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  in_file,out_file:file;
  key:array[1..8] of longint;
  x1,x2,y1,y2:longint;
  fp1:string;
  i,i1:integer;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
 case RadioGroup1.ItemIndex of
   0:Coding.Execute;
   1:Decoding.Execute;
 end;
end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
 case RadioGroup1.ItemIndex of
   0:
    begin
     Button1.Caption:='Кодировать';
     Form1.Caption:='Режим кодирования';
    end;
   1:
    begin
     Button1.Caption:='Декодировать';
     Form1.Caption:='Режим декодирования';
    end;
 end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
 OpenDialog1.Filter:='Файл ключа|*.kf';
 if OpenDialog1.Execute=true
 then
  if FileExists(OpenDialog1.FileName)=false
  then
   begin
    AssignFile(in_file,OpenDialog1.FileName+'.kf');
    rewrite(in_file,1);
    randomize;
    for i:=1 to 32 do
     begin
      i1:=random(255);
      BlockWrite(in_file,i1,1);
     end;
    Closefile(in_file);
    AssignFile(in_file,OpenDialog1.FileName+'.kf');
    reset(in_file,1);
    for i:=1 to 8 do
     BlockRead(in_file,key[i],4);
    Closefile(in_file);
    LabeledEdit3.Text:=OpenDialog1.FileName+'.kf';
   end
  else
   begin
    AssignFile(in_file,OpenDialog1.FileName);
    reset(in_file,1);
    for i:=1 to 8 do
     BlockRead(in_file,key[i],4);
    CloseFile(in_file);
    LabeledEdit3.Text:=OpenDialog1.FileName;
   end;
end;

procedure TForm1.CodingExecute(Sender: TObject);
begin
 if FileExists(LabeledEdit1.Text)=false
 then
  begin
   MessageDlg('Не выбран кодируемый файл',mtError,[mbOK],1);
   Exit;
  end
 else
  if FileExists(LabeledEdit3.Text)=false
  then
   begin
    MessageDlg('Не выбран ключевой файл',mtError,[mbOK],1);
    Exit;
   end
 else AssignFile(in_file,fp1);

 AssignFile(out_file,fp1+'cf');
 Reset(in_file,1);
 Rewrite(out_file,1);

 for i:=1 to FileSize(in_file) div 8 do
  begin
   BlockRead(in_file,x1,4);
   BlockRead(in_file,x2,4);
   for i1:=1 to 8 do
    begin
     y2:=x1 xor key[i1];
     y1:=x2 xor y2;
     x1:=y1;
     x2:=y2;
    end;
   BlockWrite(out_file,y1,4);
   BlockWrite(out_file,y2,4);
  end;
 i:=filesize(in_file)-filepos(in_file);
 case i of
  1,2,3,4:
   begin
    BlockRead(in_file,x1,i);
    x2:=0;
    for i1:=1 to 8 do
     begin
      y2:=x1 xor key[i1];
      y1:=x2 xor y2;
      x1:=y1;
      x2:=y2;
     end;
    BlockWrite(out_file,y1,4);
    BlockWrite(out_file,y2,4);
   end;
  5,6,7:
   begin
    BlockRead(in_file,x1,4);
    BlockRead(in_file,x2,i-4);
    for i1:=1 to 8 do
     begin
      y2:=x1 xor key[i1];
      y1:=x2 xor y2;
      x1:=y1;
      x2:=y2;
     end;
    BlockWrite(out_file,y1,4);
    BlockWrite(out_file,y2,4);
   end;
 end;
 Closefile(in_file);
 Closefile(out_file);
 MessageDlg('Кодирование законченно',mtWarning,[mbok],1);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 case RadioGroup1.ItemIndex of
   0:
    begin
     OpenDialog1.Filter:='Все файлы |*.*';
     if OpenDialog1.Execute=true
     then fp1:=OpenDialog1.FileName
    end;
  1:
   begin
    OpenDialog1.Filter:='Все закодированные файлы |*.*cf';
    if OpenDialog1.Execute=true
    then fp1:=OpenDialog1.FileName
   end;
 end;
 LabeledEdit1.Text:=fp1;
end;

procedure TForm1.DecodingExecute(Sender: TObject);
begin
 if FileExists(LabeledEdit1.Text)=false
 then
  begin
   MessageDlg('Не выбран декодируемый файл',mtError,[mbOK],1);
   Exit;
  end
 else
  if FileExists(LabeledEdit3.Text)=false
  then
   begin
    MessageDlg('Не выбран ключевой файл',mtError,[mbOK],1);
    Exit;
  end
 else AssignFile(in_file,fp1);

 AssignFile(out_file,copy(fp1,1,length(fp1)-2));
 Reset(in_file,1);
 Rewrite(out_file,1);

 for i:=1 to FileSize(in_file) div 8 do
  begin
   BlockRead(in_file,y1,4);
   BlockRead(in_file,y2,4);
   for i1:=8 downto 1 do
    begin
     x1:=y2 xor key[i1];
     x2:=y2 xor y1;
     y1:=x1;
     y2:=x2;
    end;
   BlockWrite(out_file,x1,4);
   BlockWrite(out_file,x2,4);
  end;
 i:=filesize(in_file)-filepos(in_file);
 case i of
  1,2,3,4:
   begin
    BlockRead(in_file,y1,i);
    y2:=0;
    for i1:=8 downto 1 do
     begin
      x1:=y2 xor key[i1];
      x2:=y2 xor y1;
      y1:=x1;
      y2:=x2;
     end;
    BlockWrite(out_file,x1,4);
    BlockWrite(out_file,x2,4);
   end;
  5,6,7:
   begin
    BlockRead(in_file,y1,4);
    BlockRead(in_file,y2,i-4);
    for i1:=8 downto 1 do
     begin
      x1:=y2 xor key[i1];
      x2:=y2 xor y1;
      y1:=x1;
      y2:=x2;
     end;
    BlockWrite(out_file,x1,4);
    BlockWrite(out_file,x2,4);
  end;
 end;
 Closefile(in_file);
 Closefile(out_file);
 MessageDlg('Декодирование законченно',mtWarning,[mbok],1);
end;

end.
