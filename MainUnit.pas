unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, RegExpr, Math;

type
  TMainForm = class(TForm)
    btnOpenFile: TButton;
    btnStart: TButton;
    memSource: TMemo;
    memResult: TMemo;
    dlOpenFile: TOpenDialog;
    memOperators: TMemo;
    memOperands: TMemo;
    lblOperatorDict: TLabel;
    lblOperandDict: TLabel;
    procedure btnStartClick(Sender: TObject);
    procedure btnOpenFileClick(Sender: TObject);
    procedure memSourceChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  source: string;
  operator_dict, operand_dict, const_strings: array of string;
  const_string_pos: array of array [1..2] of integer;
  total_operators, total_operands, unique_operators, unique_operands, prog_dictionary, prog_length, prog_volume: integer;
  log, prog_quality, prog_complexity, prog_coding_complexity, prog_info_content: Extended;
  RegExpr: TRegExpr;

implementation

{$R *.dfm}

function isInRang(position: integer): boolean;
var
  i: integer;
begin
  Result:= false;
  for i := 0 to Length(const_string_pos)-1 do
  begin
    if (position>const_string_pos[i][1]) and (position<const_string_pos[i][2]) then
      Result:= true;
  end;
end;

function isInDictionary(dict: array of string; str: string): boolean;
var
  i: integer;
begin
  Result:= false;
  for i := 0 to length(dict)-1 do
  begin
    if str = dict[i] then
      Result:= true;
  end;
end;

procedure TMainForm.btnOpenFileClick(Sender: TObject);
begin

  if dlOpenFile.Execute then
  begin
    memSource.Clear;
    memResult.Clear;
    memOperators.Clear;
    memOperands.Clear;

    memSource.Lines.LoadFromFile(dlOpenFile.FileName);
  end;
end;

procedure TMainForm.btnStartClick(Sender: TObject);
var
  i, j, pos, len :integer;
  f: boolean;
  expression: string;
begin
  source:= memSource.Text;

  try
    RegExpr:= TRegExpr.Create;
    //  удаление коментариев
    RegExpr.Expression:= '(/\*(.*?)\*/)|(//(.*?)$)|(/\*\*(.*?)\*/)';
    len:= 0;
    if RegExpr.Exec(source) then
    begin
      repeat
        pos:= RegExpr.MatchPos[0]-len;
        Delete(source,  pos, RegExpr.MatchLen[0]);
        len:= RegExpr.MatchLen[0];
      until not RegExpr.ExecNext;
    end;

    // Поиск строковых литералов
    i:= 0;
    SetLength(const_string_pos, 0);
    SetLength(const_strings, 0);
    RegExpr.Expression:= '"(.*?)"';
    if RegExpr.Exec(source) then
    begin
      repeat
        SetLength(const_string_pos, length(const_string_pos)+1);
        const_string_pos[i][1]:= RegExpr.MatchPos[0];
        const_string_pos[i][2]:= RegExpr.MatchPos[0] + RegExpr.MatchLen[0];
        SetLength(const_strings, length(const_strings)+1);
        const_strings[i]:= RegExpr.Match[0];
        i:= i+1;
      until not RegExpr.ExecNext;
    end;

  // Поиск операторов

    SetLength(operator_dict, 0);
    unique_operators:= 0;
    total_operators:= 0;
    //                     сдвига      арифметические + присваивания                                         отношения              логические
    RegExpr.Expression:= '(\>\>|\<\<)|(\+\+|--|\+=|-=|\*=|/=|%=|&=|\|=|^=|\>\>\>=|\<\<=|\>\>=|\+|-|\*|/|%)|(==|!=|\>=|\<=|\>|\<|=)|(\|\||&&|\||&|\^|!)';
    if RegExpr.Exec(source) then
    begin
      repeat
        if not isInRang(RegExpr.MatchPos[0]) then
          if not isInDictionary(operator_dict, RegExpr.Match[0]) then
          begin
            SetLength(operator_dict, length(operator_dict)+1);
            operator_dict[length(operator_dict)-1]:= RegExpr.Match[0];
            unique_operators:= unique_operators+1;
            total_operators:= total_operators+1;
          end
          else
            total_operators:= total_operators+1;
      until not RegExpr.ExecNext;
    end;
                          //      управляющие и циклы                                                                                            приведение типов
   RegExpr.Expression:= '(\bif\b|\belse\b|\bswitch\b|\bfor\b|\bwhile\b|\bdo\b|\bbreak\b|\bcontinue\b|\breturn\b|\bnew\b|\bdelete\b|\bclass\b|\bcase\b)|(\s\([\w_][\d\w_]*\))';
   if RegExpr.Exec(source) then
    begin
      repeat
        if not isInRang(RegExpr.MatchPos[0]) then
          if not isInDictionary(operator_dict, RegExpr.Match[0]) then
          begin
            SetLength(operator_dict, length(operator_dict)+1);
            operator_dict[length(operator_dict)-1]:= RegExpr.Match[0];
            unique_operators:= unique_operators+1;
            total_operators:= total_operators+1;
          end
          else
            total_operators:= total_operators+1;
      until not RegExpr.ExecNext;
    end;

   // операторы .(обращение к полю) ? : оператор []  вызовы процедур и функций
    RegExpr.Expression:= '(\.|\?)|(\[(\d|\w+)\])|(\b[\w_][\d\w_\.]*\((.*?)\))';
    if RegExpr.Exec(source) then
    begin
      repeat
        if not isInRang(RegExpr.MatchPos[0]) then
        begin

            expression:= RegExpr.Match[0];
          if not isInDictionary(operator_dict, expression) then
          begin
            SetLength(operator_dict, length(operator_dict)+1);
            operator_dict[length(operator_dict)-1]:= expression;
            unique_operators:= unique_operators+1;
            total_operators:= total_operators+1;
          end
          else
            total_operators:= total_operators+1;
        end;
      until not RegExpr.ExecNext;
    end;

    SetLength(operand_dict, 0);
    unique_operands:= 0;
    total_operands:= 0;
  // Поиск операндов
    {
      Простые типы данных Java: boolean, byte, char, double, float, int, long, short
    }
    // Поиск переменных простых типов
    RegExpr.Expression:= '\b[\w_][\d\w_]*[^\(\)\.\[\]]\b';
    if RegExpr.Exec(source) then
    begin
      repeat
        if not isInRang(RegExpr.MatchPos[0]) then
          if (not isInDictionary(operand_dict, RegExpr.Match[0])) then
          begin
            SetLength(operand_dict, length(operand_dict)+1);
            operand_dict[length(operand_dict)-1]:= RegExpr.Match[0];
            unique_operands:= unique_operands+1;
            total_operands:= total_operands+1;
          end
          else
            total_operands:= total_operands+1;
      until not RegExpr.ExecNext;
    end;

    // Поиск литералов
                         // int, long, float, double    16-ные                8-ные        2-ные            экспотенциальная запись        символьные литералы ' '
    RegExpr.Expression:= '(\b\d+\.*[Ll]*[Ff]*[Dd]*\b)|(\b0[Xx]\d*[A-F]*\b)|(\b0[0-8]*\b)|(\b0[Bb][01]*\b)|(\b\d+\.\d+[Ee][+-]\d+[Ff]*\b)|(''\\?.?'')';
    if RegExpr.Exec(source) then
    begin
      repeat
        if not isInRang(RegExpr.MatchPos[0]) then
          if not isInDictionary(operand_dict, RegExpr.Match[0]) then
          begin
            SetLength(operand_dict, length(operand_dict)+1);
            operand_dict[length(operand_dict)-1]:= RegExpr.Match[0];
            unique_operands:= unique_operands+1;
            total_operands:= total_operands+1;
          end
          else
            total_operands:= total_operands+1;
      until not RegExpr.ExecNext;
    end;

    for i := 0 to Length(operand_dict)-1 do
    begin
      for j := 0 to Length(operator_dict)-1 do
        if  Trim(operand_dict[i])=Trim(operator_dict[j])  then
        begin
          operand_dict[i]:= operand_dict[length(operand_dict)-1];
          SetLength(operand_dict, length(operand_dict)-1);
          unique_operands:= unique_operands-1;
          total_operands:= total_operands-1;
        end;
    end;

    for i := 0 to Length(const_strings)-1 do
    begin
      SetLength(operand_dict, length(operand_dict)+1);
      operand_dict[length(operand_dict)-1]:= const_strings[i];
    end;

    for i := 0 to Length(operator_dict)-1 do
    begin
      for j := 0 to length(operator_dict[i])-1 do
        if operator_dict[i][j]= '(' then
        begin
          SetLength(operator_dict[i], j+1);
           operator_dict[i][j+1]:= ')';
        end;
    end;

  finally
    RegExpr.Free;
  end;

  // рассчет показателей программы
  prog_dictionary:= unique_operators + unique_operands;
  prog_length:= total_operators + total_operands;
  log:= log2(prog_dictionary);
  prog_volume:= prog_length * Trunc(log);
  prog_quality:= (2*unique_operands) / (unique_operators*total_operands);
  prog_complexity:= prog_volume / (2*prog_quality);
  prog_coding_complexity:= 1 / prog_quality;
  prog_info_content:= prog_volume / prog_coding_complexity;

  memOperators.Visible:= true;
  memOperands.Visible:= true;
  lblOperatorDict.Visible:= true;
  lblOperandDict.Visible:= true;
  memOperators.Clear;
  memOperands.Clear;
  memResult.Clear;
  memResult.Lines.Add('Уникальных операторов программы: '+ IntToStr(unique_operators));
  memResult.Lines.Add('Уникальных операндов программы: '+ IntToStr(unique_operands));
  memResult.Lines.Add('Всего операторов: '+ IntToStr(total_operators));
  memResult.Lines.Add('Всего операндов: '+ IntToStr(total_operands));
  memResult.Lines.Add('Словарь программы: '+ IntToStr(prog_dictionary));
  memResult.Lines.Add('Длина программы: '+ IntToStr(prog_length));
  memResult.Lines.Add('Объем программы: '+ IntToStr(prog_volume));
  memResult.Lines.Add('Уровень качества программирования: '+ FloatToStr(prog_quality));
  memResult.Lines.Add('Сложность понимания программы: '+ FloatToStr(prog_complexity));
  memResult.Lines.Add('Трудоемкость кодирования программы: '+ FloatToStr(prog_coding_complexity));
  memResult.Lines.Add('Информационное содержание программы: '+ FloatToStr(prog_info_content));

  for i := 0 to Length(operator_dict)-1 do
    memOperators.Lines.Add(operator_dict[i]);
  for i := 0 to Length(operand_dict)-1 do
    memOperands.Lines.Add(operand_dict[i]);
end;

procedure TMainForm.memSourceChange(Sender: TObject);
begin
  if length(memSource.Text)<>0 then
    btnStart.Enabled:= true
  else
    btnStart.Enabled:= false;
end;

end.
