unit principal;


interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  Buttons, StdCtrls, ExtDlgs, Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Image2: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    SavePictureDialog1: TSavePictureDialog;
    procedure Button1Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);

    // Operações
    procedure ConverterCinza;
    procedure EqualizacaoImagem;
    procedure AdicionarRuido;
    procedure FiltroMedia;
    procedure FiltroMediana;
    procedure Binarizacao;
    procedure FiltroLaplaciano;
    procedure BordaSobel;
    procedure Compressao;
    procedure Limiarizacao;
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  ImgWidth, ImgHeight: Integer;
  ImE, ImS: array of array of Integer;
  cor : TColor;

implementation
{$R *.lfm}

// Operações
procedure TForm1.ConverterCinza;
var
   i, j, R, G, B, k: Integer;
begin
  for i := 0 to ImgWidth - 1 do
      for j := 0 to ImgHeight - 1 do
          begin
            cor := Image1.Canvas.Pixels[i, j];
            R := GetRValue(cor);
            G := GetGValue(cor);
            B := GetBValue(cor);

            k := (R + G + B) div 3;

            ImS[i, j] := k;
            Image2.Canvas.Pixels[i, j] := RGB(k, k, k);
          end;
end;

procedure TForm1.EqualizacaoImagem;
var
   i, j, k, tomCinza : Integer;

   histograma: array[0..255] of Integer; // Ocorrências de tonz de cinza.
   freqAcumulada : array[0..255] of Integer;
begin
  for k := 0 to 255 do
      begin
        histograma[k] := 0;
        freqAcumulada[k] := 0;
      end;

  // Preenche o histograma.
  for i := 0 to ImgWidth - 1 do
      for j := 0 to ImgHeight - 1 do
          begin
            tomCinza := ImE[i, j];

            histograma[tomCinza] += 1;
          end;

  // Preenchendo a frequencia acumulada.
  freqAcumulada[0] := histograma[0];
  for k := 1 to 255 do
      freqAcumulada[k] := freqAcumulada[k - 1] + histograma[k];

  // Equalizacao.
  for i := 0 to ImgWidth - 1 do
      for j := 0 to ImgHeight - 1 do
          begin
            tomCinza := ImE[i, j];

            // 255 é o número de tons de cinza.
            ImS[i, j] :=
                        max(0, round(
                                   (255 * freqAcumulada[tomCinza]) /
                                         (ImgHeight * ImgWidth)
                                    ) - 1
                        );

            Image2.Canvas.Pixels[i, j] := RGB(ImS[i, j], ImS[i, j], ImS[i, j]);
          end;
end;

procedure TForm1.AdicionarRuido;
var
   i, j, k, ruido, N : Integer;
begin
  N := ImgWidth * ImgHeight div 10; // 10% de ruído

  for k := 1 to N do
      begin
        i := random(ImgWidth);
        j := random(ImgHeight);

        ruido := random(100);

        if ruido > 50 then ruido := 255
        else ruido := 0;

        ImS[i, j] := ruido;
        Image2.Canvas.Pixels[i, j] := RGB(ruido, ruido, ruido);
      end;
end;

procedure TForm1.FiltroMedia;
var
   i, j, media : Integer;
begin
  for i := 1 to ImgWidth - 2 do
   for j := 1 to ImgHeight - 2 do
    begin
      media := (
        ImE[i - 1, j - 1] + ImE[i, j - 1]     + ImE[i + 1, j - 1] +
        ImE[i - 1, j]     + ImE[i, j]         + ImE[i + 1, j] +
        ImE[i - 1, j + 1] + ImE[i - 1, j + 1] + ImE[i + 1, j + 1]
      ) div 9;

      ImS[i, j] := media;

      Image2.Canvas.Pixels[i, j] := RGB(media, media, media);
    end;
end;

procedure TForm1.FiltroMediana;
var
   vetor : array [0..8] of Integer;  // Vizinhos
   i, j, k, x, y : Integer;
begin
  for i := 1 to ImgWidth - 2 do
   for j := 1 to ImgHeight - 2 do
    begin
      vetor[0] := ImE[i - 1, j - 1];
      vetor[1] := ImE[i, j - 1];
      vetor[2] := ImE[i + 1, j - 1];

      vetor[3] := ImE[i - 1, j];
      vetor[4] := ImE[i, j];
      vetor[5] := ImE[i + 1, j];

      vetor[6] := ImE[i - 1, j + 1];
      vetor[7] := ImE[i, j + 1];
      vetor[8] := ImE[i + 1, j + 1];

      for y := 0 to 7 do                 // Ordena o vetor
       for x := 0 to 7 do
        if vetor[x] > vetor[x + 1]
           then
           begin
             k := vetor[x];
             vetor[x] := vetor[x + 1];
             vetor[x + 1] := k;
           end;

      ImS[i, j] := vetor[4]; // Valor Mediano
      Image2.Canvas.Pixels[i, j] := RGB(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;
end;

procedure TForm1.Binarizacao;
var
   i, j : Integer;
begin
  for j := 0 to ImgHeight - 1 do
   for i := 0 to ImgWidth - 1 do
    begin
      if (ImE[i, j] < 128)
      then
          ImS[i, j] := 0
      else
          ImS[i, j] := 255;

      Image2.Canvas.Pixels[i, j] := RGB(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;
end;

procedure TForm1.FiltroLaplaciano;
var
   i, j, Lapl, max : Integer;
begin
  for i := 1 to ImgWidth - 2 do
   for j := 1 to ImgHeight - 2 do
    begin
      Lapl := -ImE[i + 1, j] - ImE[i - 1, j]
                   - ImE[i, j + 1] - ImE[i, j - 1] + 4 * ImE[i, j];

      Lapl := abs(Lapl);

      ImS[i, j] := Lapl;
    end;

  // Normaliazação da imagem. Pegamos o maior valor e deixamos como 255.
  // É uma regra de três pixel * (255 / max).
  max := 0;
  for i := 0 to ImgWidth - 1 do
   for j := 0 to ImgHeight - 1 do
    if (ImS[i, j] > max) then max := ImS[i, j];

  for i := 0 to ImgWidth - 1 do
   for j := 0 to ImgHeight - 1 do
    begin
      ImS[i, j] := ImS[i, j] * 255 div max;

      Image2.Canvas.Pixels[i, j] := RGB(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;

end;

procedure TForm1.BordaSobel;
begin

end;

procedure TForm1.Compressao;
begin;

end;

procedure TForm1.Limiarizacao;
begin;

end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  SavePictureDialog1.DefaultExt := 'bmp';
  if (SavePictureDialog1.Execute()) then Image1.Picture.SaveToFile(SavePictureDialog1.FileName);
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  close();
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  ConverterCinza;
end;

procedure TForm1.MenuItem7Click(Sender: TObject);
begin
  AdicionarRuido;
end;

procedure TForm1.MenuItem8Click(Sender: TObject);
begin
  FiltroMedia;
end;

procedure TForm1.MenuItem9Click(Sender: TObject);
begin
  FiltroMediana;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
end;

procedure TForm1.MenuItem10Click(Sender: TObject);
begin
  Binarizacao;
end;

procedure TForm1.MenuItem11Click(Sender: TObject);
begin
  FiltroLaplaciano;
end;

procedure TForm1.MenuItem12Click(Sender: TObject);
begin
  EqualizacaoImagem;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   i, j : Integer;
begin
  Image1.Picture.Assign(Image2.Picture);
  for i := 0 to ImgWidth - 1 do
      for j := 0 to ImgHeight - 1 do
          ImE[i, j] := ImS[i, j];
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  if (OpenDialog1.Execute()) then Image1.Picture.LoadFromFile(OpenDialog1.Filename);
  // Reseta a Imagem 2 se ela estiver preenchida.
  if (Image2.Picture.Graphic <> nil) then Image2.Picture.Clear;

  Image1.AutoSize := True;

  ImgWidth := Image1.Picture.Width;
  ImgHeight := Image1.Picture.Height;

  Image2.Width := Image1.Picture.Width;
  Image2.Height := Image1.Picture.Height;

  SetLength(ImE, ImgWidth, ImgHeight);
  SetLength(ImS, ImgWidth, ImgHeight);

  // Posiciona a Imagem 2 em Largura do botão + 50% da largura da Imagem1
  // O Image2 será posicionado logo após esse espaço
  // Consideremos a distancia do meio na borda direita até o meio da borda esquerda.
  Image2.Left := (Image1.Left + Image1.Width) + (Button1.Width + Image1.Width div 2);
  Image2.Top := Image1.Top;

  // Posicionar o botao no meio entre as duas imagens.
  Button1.Left := (Image1.Left + Image1.Width) + Image1.Width div 4;
  Button1.Top := (Image1.Top + Image1.Height) div 2;

end;

end.

