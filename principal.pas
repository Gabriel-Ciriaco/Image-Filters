unit principal;


interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus, Math,
  Buttons, StdCtrls, ExtDlgs, ComCtrls, Spin, Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    EditMagnitude: TEdit;
    EditDirecao: TEdit;
    Image1: TImage;
    Image2: TImage;
    MainMenu1: TMainMenu;
    Arquivo: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    Laplaciano8: TMenuItem;
    MenuItemLimiarizacaoOtsu: TMenuItem;
    MenuItemEqualizacaoHSL: TMenuItem;
    MenuItemPseudoCores: TMenuItem;
    MenuItemPontoMedio: TMenuItem;
    MenuItemMaximo: TMenuItem;
    MenuItemMinimo: TMenuItem;
    Operacoes: TMenuItem;
    Abrir: TMenuItem;
    Salvar: TMenuItem;
    Sair: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    SavePictureDialog1: TSavePictureDialog;
    procedure Button1Click(Sender: TObject);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Laplaciano8Click(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem13Click(Sender: TObject);
    procedure AbrirClick(Sender: TObject);

    // Operações
    procedure ConverterCinza;
    procedure InverterCinza;
    procedure EqualizacaoImagem;
    procedure AdicionarRuido;
    procedure FiltroMedia;
    procedure FiltroMediana;
    procedure FiltroMinimo;
    procedure FiltroMaximo;
    procedure FiltroPontoMedio;
    procedure Binarizacao;
    procedure FiltroLaplaciano;
    procedure FiltroLaplaciano8;
    procedure BordaSobel;
    procedure Compressao(c: Float; y: Float);
    procedure Limiarizacao(t: Integer);
    procedure MenuItemEqualizacaoHSLClick(Sender: TObject);
    procedure MenuItemLimiarizacaoOtsuClick(Sender: TObject);
    procedure MenuItemPseudoCoresClick(Sender: TObject);
    procedure PseudoCores;
    procedure EqualizacaoHSL;
    procedure LimiarizacaoOtsu;
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItemMaximoClick(Sender: TObject);
    procedure MenuItemMinimoClick(Sender: TObject);
    procedure MenuItemPontoMedioClick(Sender: TObject);
    procedure SalvarClick(Sender: TObject);
    procedure SairClick(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
  private
    magnitudes : array of array of Integer; // Array dinâmico com as magnitudes.
    magDirecoes : array of array of Double;

    SobelAtivo : Boolean;
    procedure DesativarSobel;

  public

  end;

var
  Form1: TForm1;
  ImgWidth, ImgHeight: Integer;
  ImE, ImS: array of array of Integer;
  cor : TColor;

implementation
{$R *.lfm}

procedure TForm1.DesativarSobel;
begin
  SobelAtivo := False;
  EditMagnitude.Visible := False;
  EditDirecao.Visible := False;
end;

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

procedure TForm1.InverterCinza;
var
   i, j : Integer;
begin
  for i := 0 to ImgWidth - 1 do
      for j := 0 to ImgHeight - 1 do
          begin
            ImS[i, j] := 255 - ImE[i, j];

            Image2.Canvas.Pixels[i, j] := RGB(ImS[i, j], ImS[i, j], ImS[i, j]);
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

procedure TForm1.FiltroMinimo;
var
   i, j, k, minVal : Integer;
   vizinhos : array[0..8] of Integer;
begin
  for i := 1 to ImgWidth - 2 do
   for j := 1 to ImgHeight - 2 do
    begin
      vizinhos[0] := ImE[i - 1, j - 1];
      vizinhos[1] := ImE[i,     j - 1];
      vizinhos[2] := ImE[i + 1, j - 1];
      vizinhos[3] := ImE[i - 1, j    ];
      vizinhos[4] := ImE[i,     j    ];
      vizinhos[5] := ImE[i + 1, j    ];
      vizinhos[6] := ImE[i - 1, j + 1];
      vizinhos[7] := ImE[i,     j + 1];
      vizinhos[8] := ImE[i + 1, j + 1];

      minVal := vizinhos[0];
      for k := 1 to 8 do
        if vizinhos[k] < minVal then minVal := vizinhos[k];

      ImS[i, j] := minVal;
      Image2.Canvas.Pixels[i, j] := RGB(minVal, minVal, minVal);
    end;
end;

procedure TForm1.FiltroMaximo;
var
   i, j, k, maxVal : Integer;
   vizinhos : array[0..8] of Integer;
begin
  for i := 1 to ImgWidth - 2 do
   for j := 1 to ImgHeight - 2 do
    begin
      vizinhos[0] := ImE[i - 1, j - 1];
      vizinhos[1] := ImE[i,     j - 1];
      vizinhos[2] := ImE[i + 1, j - 1];
      vizinhos[3] := ImE[i - 1, j    ];
      vizinhos[4] := ImE[i,     j    ];
      vizinhos[5] := ImE[i + 1, j    ];
      vizinhos[6] := ImE[i - 1, j + 1];
      vizinhos[7] := ImE[i,     j + 1];
      vizinhos[8] := ImE[i + 1, j + 1];

      maxVal := vizinhos[0];
      for k := 1 to 8 do
        if vizinhos[k] > maxVal then maxVal := vizinhos[k];

      ImS[i, j] := maxVal;
      Image2.Canvas.Pixels[i, j] := RGB(maxVal, maxVal, maxVal);
    end;
end;

procedure TForm1.FiltroPontoMedio;
var
   i, j, k, minVal, maxVal : Integer;
   vizinhos : array[0..8] of Integer;
   pontoMedio : Integer;
begin
  for i := 1 to ImgWidth - 2 do
   for j := 1 to ImgHeight - 2 do
    begin
      vizinhos[0] := ImE[i - 1, j - 1];
      vizinhos[1] := ImE[i,     j - 1];
      vizinhos[2] := ImE[i + 1, j - 1];
      vizinhos[3] := ImE[i - 1, j    ];
      vizinhos[4] := ImE[i,     j    ];
      vizinhos[5] := ImE[i + 1, j    ];
      vizinhos[6] := ImE[i - 1, j + 1];
      vizinhos[7] := ImE[i,     j + 1];
      vizinhos[8] := ImE[i + 1, j + 1];

      minVal := vizinhos[0];
      maxVal := vizinhos[0];
      for k := 1 to 8 do
        begin
          if vizinhos[k] < minVal then minVal := vizinhos[k];
          if vizinhos[k] > maxVal then maxVal := vizinhos[k];
        end;

      pontoMedio := (minVal + maxVal) div 2;

      ImS[i, j] := pontoMedio;
      Image2.Canvas.Pixels[i, j] := RGB(pontoMedio, pontoMedio, pontoMedio);
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

  // Normalização da imagem. Pegamos o maior valor e deixamos como 255.
  // É uma regra de três: pixel * (255 / max).
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

procedure TForm1.FiltroLaplaciano8;
var
   i, j, Lapl, max : Integer;
begin
  for i := 1 to ImgWidth - 2 do
   for j := 1 to ImgHeight - 2 do
    begin
      Lapl := -ImE[i - 1, j - 1] - ImE[i, j - 1] - ImE[i + 1, j - 1]
              -ImE[i - 1, j]                       - ImE[i + 1, j]
              -ImE[i - 1, j + 1] - ImE[i, j + 1]  - ImE[i + 1, j + 1]
              + 8 * ImE[i, j];

      Lapl := abs(Lapl);

      ImS[i, j] := Lapl;
    end;

  // Normalização
  max := 0;
  for i := 0 to ImgWidth - 1 do
   for j := 0 to ImgHeight - 1 do
    if (ImS[i, j] > max) then max := ImS[i, j];

  if max = 0 then max := 1; // Prevenir divisão por zero

  for i := 0 to ImgWidth - 1 do
   for j := 0 to ImgHeight - 1 do
    begin
      ImS[i, j] := ImS[i, j] * 255 div max;
      Image2.Canvas.Pixels[i, j] := RGB(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;
end;

procedure TForm1.BordaSobel;
var
   i, j, SobelX, SobelY, minMag, maxMag, diffMag : Integer;
begin
  SetLength(magnitudes, ImgWidth, ImgHeight);
  SetLength(magDirecoes, ImgWidth, ImgHeight);

  for i := 0 to ImgWidth - 1 do
   for j := 0 to ImgHeight - 1 do
    begin
      magnitudes[i, j] := 0;
      magDirecoes[i, j] := 0;
    end;


  minMag := 255;
  maxMag := 0;
  // Cálculo das bordas de sobel.
  for i := 1 to ImgWidth - 2 do
   for j := 1 to ImgHeight - 2 do
    begin
      SobelX :=  (-    ImE[i - 1, j - 1]  +     ImE[i - 1, j + 1]
                  -2 * ImE[i, j - 1]      + 2 * ImE[i, j + 1]
                  -    ImE[i + 1, j - 1]  +     ImE[i + 1, j + 1]) div 4;

      SobelY :=  (-ImE[i - 1, j - 1] - 2 * ImE[i - 1, j] - ImE[i - 1, j + 1]
                  +ImE[i + 1, j - 1] + 2 * ImE[i + 1, j] + ImE[i + 1, j + 1]) div 4;

      magnitudes[i , j] := Round(Sqrt(SobelX * SobelX + SobelY * SobelY));

      // Encontrar o mínimo e máximo da magnitude.
      if minMag > magnitudes[i, j] then minMag := magnitudes[i, j];
      if maxMag < magnitudes[i, j] then maxMag := magnitudes[i, j];

      magDirecoes[i, j] := ArcTan2(SobelY, SobelX);
    end;


  diffMag := maxMag - minMag;

  if diffMag = 0 then diffMag := 1; // Previnir divisão por zero.

  // Normalização com mínimo e máximo da magnitude
  for i := 0 to ImgWidth - 1 do
   for j := 0 to ImgHeight - 1 do
    begin
      ImS[i, j] := Round(255 * ((magnitudes[i, j] - minMag) / diffMag));

      Image2.Canvas.Pixels[i, j] := RGB(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;

end;

procedure TForm1.Compressao(c: Float; y: Float);
var
   i, j : Integer;
   r, S : Double;
begin
  for i := 0 to ImgWidth - 1 do
   for j := 0 to ImgHeight - 1 do
    begin
      r := ImE[i , j] / 255.0;  // Valor do pixel normalizado.

      S := c * Power(r, y);

      // Deixa S entre 0 e 1.
      if S > 1.0 then S := 1.0;
      if S < 0.0 then S := 0.0;

      ImS[i, j] := Round(S * 255); // Valor reajustado na escala [0, 255].

      Image2.Canvas.Pixels[i, j] := RGB(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;
end;

procedure TForm1.Limiarizacao(t: Integer);
var
   i, j : Integer;
begin
  for i := 0 to ImgWidth - 1 do
   for j := 0 to ImgHeight - 1 do
    begin
      if ImE[i, j] < t then ImS[i, j] := 0;
      if ImE[i, j] >= t then ImS[i, j] := ImE[i, j];

      Image2.Canvas.Pixels[i, j] := RGB(ImS[i, j], ImS[i, j], ImS[i, j]);
    end;
end;

procedure TForm1.MenuItemEqualizacaoHSLClick(Sender: TObject);
begin
  DesativarSobel;
  EqualizacaoHSL;
end;

procedure TForm1.MenuItemLimiarizacaoOtsuClick(Sender: TObject);
begin
  DesativarSobel;
  LimiarizacaoOtsu;
end;

procedure TForm1.MenuItemPseudoCoresClick(Sender: TObject);
begin
  DesativarSobel;
  PseudoCores;
end;

procedure TForm1.PseudoCores;
var
  i, j, v : Integer;
  R, G, B : Integer;
begin
  for i := 0 to ImgWidth - 1 do
   for j := 0 to ImgHeight - 1 do
    begin
      v := ImE[i, j]; // Valor do pixel em cinza (0-255)

      // Preto (0) para Azul (64) para Ciano (128) para Verde (192) para Amarelo (255)
      if v < 64 then        // Preto para Azul
        begin
          R := 0;
          G := 0;
          B := Round(v * 255 / 64);
        end
      else if v < 128 then  // Azul para Ciano
        begin
          R := 0;
          G := Round((v - 64) * 255 / 64);
          B := 255;
        end
      else if v < 192 then  // Ciano para Verde
        begin
          R := 0;
          G := 255;
          B := Round((192 - v) * 255 / 64);
        end
      else                  // Verde para Amarelo
        begin
          R := Round((v - 192) * 255 / 63);
          G := 255;
          B := 0;
        end;

      Image2.Canvas.Pixels[i, j] := RGB(R, G, B);
    end;
end;

procedure TForm1.EqualizacaoHSL;
var
  i, j, k : Integer;
  R, G, B  : Integer;
  H, S, L  : Double;
  Lint     : Integer;
  histograma    : array[0..255] of Integer;
  freqAcumulada : array[0..255] of Integer;

  procedure RGBtoHSL(R, G, B: Integer; out H, S, L: Double);
  var
    Rn, Gn, Bn, Cmax, Cmin, Delta: Double;
  begin
    Rn := R / 255.0;
    Gn := G / 255.0;
    Bn := B / 255.0;

    Cmax := Rn;
    if Gn > Cmax then Cmax := Gn;
    if Bn > Cmax then Cmax := Bn;

    Cmin := Rn;
    if Gn < Cmin then Cmin := Gn;
    if Bn < Cmin then Cmin := Bn;

    Delta := Cmax - Cmin;

    L := (Cmax + Cmin) / 2.0;

    // Saturação
    if (Delta = 0) or (L = 0) or (L = 1) then
      S := 0
    else
      S := Delta / (1 - Abs(2 * L - 1));

    // Matiz
    if Delta = 0 then
      H := 0
    else if Cmax = Rn then
      begin
        H := 60 * ((Gn - Bn) / Delta);
        if H < 0 then H := H + 360;
      end
    else if Cmax = Gn then
      H := 60 * (((Bn - Rn) / Delta) + 2)
    else
      H := 60 * (((Rn - Gn) / Delta) + 4);
  end;

  procedure HSLtoRGB(H, S, L: Double; out R, G, B: Integer);
  var
    C, X, M, Rn, Gn, Bn: Double;
  begin
    C := (1 - Abs(2 * L - 1)) * S;
    X := C * (1 - Abs((H / 60) - Floor(H / 60 / 2) * 2 - 1));
    M := L - C / 2;

    if H < 60 then begin Rn := C; Gn := X; Bn := 0; end
    else if H < 120 then begin Rn := X; Gn := C; Bn := 0; end
    else if H < 180 then begin Rn := 0; Gn := C; Bn := X; end
    else if H < 240 then begin Rn := 0; Gn := X; Bn := C; end
    else if H < 300 then begin Rn := X; Gn := 0; Bn := C; end
    else begin Rn := C; Gn := 0; Bn := X; end;

    R := Round((Rn + M) * 255);
    G := Round((Gn + M) * 255);
    B := Round((Bn + M) * 255);

    if R > 255 then R := 255;
    if R < 0   then R := 0;
    if G > 255 then G := 255;
    if G < 0   then G := 0;
    if B > 255 then B := 255;
    if B < 0   then B := 0;
  end;

begin
  for k := 0 to 255 do
  begin
    histograma[k]    := 0;
    freqAcumulada[k] := 0;
  end;

  // Monta histograma do canal L
  for i := 0 to ImgWidth - 1 do
   for j := 0 to ImgHeight - 1 do
    begin
      cor := Image1.Canvas.Pixels[i, j];
      RGBtoHSL(GetRValue(cor), GetGValue(cor), GetBValue(cor), H, S, L);

      Lint := Round(L * 255);
      histograma[Lint] += 1;
    end;

  // Frequência acumulada
  freqAcumulada[0] := histograma[0];
  for k := 1 to 255 do
    freqAcumulada[k] := freqAcumulada[k - 1] + histograma[k];

  // Aplica equalização só no L e reconverte para RGB
  for i := 0 to ImgWidth - 1 do
   for j := 0 to ImgHeight - 1 do
    begin
      cor := Image1.Canvas.Pixels[i, j];
      RGBtoHSL(GetRValue(cor), GetGValue(cor), GetBValue(cor), H, S, L);

      Lint := Round(L * 255);

      // Equaliza o L
      Lint := Round((255 * freqAcumulada[Lint]) / (ImgHeight * ImgWidth)) - 1;
      if Lint < 0 then Lint := 0;
      L := Lint / 255.0;

      HSLtoRGB(H, S, L, R, G, B);

      Image2.Canvas.Pixels[i, j] := RGB(R, G, B);
    end;
end;

procedure TForm1.LimiarizacaoOtsu;
var
  i, j, t, Threshold : Integer;
  w0, uT, uT_classe, SigB2, SigT2, nf, nmin, n, x, y : Double;
  pI : array[1..256] of Double;
  ni : array[1..256] of Double;
  jMin, kMax : Integer;
begin
  n := (ImgWidth - 4.0) * (ImgHeight - 4.0);

  for i := 1 to 256 do
    ni[i] := 0.0;

  for i := 2 to ImgWidth - 3 do
   for j := 2 to ImgHeight - 3 do
    ni[ImE[i, j] + 1] := ni[ImE[i, j] + 1] + 1.0;

  for i := 1 to 256 do
    pI[i] := ni[i] / n; // pi : probabilidade de ocorrer o valor i na imagem

  uT := 0.0; // uT : média global da imagem
  for i := 1 to 256 do
    uT := uT + i * pI[i];

  SigT2 := 0.0; // SigmaT2 : variância global da imagem
  for i := 1 to 256 do
    SigT2 := SigT2 + (i - uT) * (i - uT) * pI[i];

  jMin := -1;
  kMax := -1;
  for i := 1 to 256 do
  begin
    if (jMin < 0) and (pI[i] > 0.0) then jMin := i; // acha o menor com pi[i] != 0
    if (pI[i] > 0.0) then kMax := i;                 // acha o maior com pi[i] != 0
  end;

  nmin := -1.0;
  Threshold := jMin;

  for t := jMin to kMax do
  begin
    uT_classe := 0.0;
    for i := 1 to t do
      uT_classe := uT_classe + i * pI[i];

    w0 := 0.0;
    for i := 1 to t do
      w0 := w0 + pI[i];

    x := (uT * w0 - uT_classe);
    x := x * x;
    y := w0 * (1.0 - w0);

    if y > 0.0 then
      x := x / y
    else
      x := 0.0;

    SigB2 := x;

    if SigT2 > 0.0 then
      nf := SigB2 / SigT2
    else
      nf := 0.0;

    if nf >= nmin then
    begin
      nmin := nf;
      Threshold := t - 1;
    end;
  end;
  ShowMessage('Threshold OTSU encontrado: ' + IntToStr(Threshold));
  Limiarizacao(Threshold);
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  DesativarSobel;
  ConverterCinza;
end;

procedure TForm1.MenuItem7Click(Sender: TObject);
begin
  DesativarSobel;
  AdicionarRuido;
end;

procedure TForm1.MenuItem8Click(Sender: TObject);
begin
  DesativarSobel;
  FiltroMedia;
end;

procedure TForm1.MenuItem9Click(Sender: TObject);
begin
  DesativarSobel;
  FiltroMediana;
end;

procedure TForm1.MenuItem10Click(Sender: TObject);
begin
  DesativarSobel;
  Binarizacao;
end;

procedure TForm1.MenuItem11Click(Sender: TObject);
begin
  DesativarSobel;
  FiltroLaplaciano;
end;

procedure TForm1.MenuItem12Click(Sender: TObject);
begin
  DesativarSobel;
  EqualizacaoImagem;
end;

procedure TForm1.MenuItem13Click(Sender: TObject);
begin
  SobelAtivo := True;
  EditMagnitude.Visible := True;
  EditDirecao.Visible := True;

  BordaSobel;
end;

function CorrigirDecimal(const S: String): String;
begin
  Result := StringReplace(S, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := StringReplace(Result, '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
var
   strValues : array[0..1] of String;
   c, y : Float;
begin
  DesativarSobel;

  // Usamos o separador padrão do sistema do usuário (, ou .).
  strValues[0] := '1' + FormatSettings.DecimalSeparator + '0';
  strValues[1] := '0' + FormatSettings.DecimalSeparator + '6';

  if InputQuery('Definir Compressao',
     ['Digite o valor de C:', 'Digite o valor de Y:'], strValues) then
     begin
       // Aceitar , ou . para os decimais.
       c := StrToFloatDef(CorrigirDecimal(strValues[0]), 1.0);
       y := StrToFloatDef(CorrigirDecimal(strValues[1]), 0.6);

       Compressao(c, y);
     end;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
var
   S : String;
   t : Integer;
begin
  DesativarSobel;

  S := '128';
  if InputQuery('Definir Limiar', 'Digite o valor do Limiar:', S) then
  begin
    t :=  StrToIntDef(S, 128);

    Limiarizacao(t);
  end;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  DesativarSobel;
  InverterCinza;
end;

procedure TForm1.MenuItemMaximoClick(Sender: TObject);
begin
  DesativarSobel;
  FiltroMaximo;
end;

procedure TForm1.MenuItemMinimoClick(Sender: TObject);
begin
  DesativarSobel;
  FiltroMinimo;
end;

procedure TForm1.MenuItemPontoMedioClick(Sender: TObject);
begin
  DesativarSobel;
  FiltroPontoMedio;
end;

// Botões Adicionais (Ajudam nas Operações com Imagens).
procedure TForm1.Image2MouseMove(Sender: TObject; Shift: TShiftState;
                                                         X, Y: Integer);
var
   magDirecao : Float;
begin
  if not SobelAtivo then Exit;

  // Verifica se o mouse está dentro dos limites calculados (evitar erros de índice)
  if (X >= 1) and (X <= ImgWidth - 2) and (Y >= 1) and (Y <= ImgHeight - 2) then
  begin
    if (magnitudes <> nil) and (magDirecoes <> nil) then
       begin
         magDirecao := magDirecoes[X, Y] * (180 / PI);

         if magDirecao < 0 then magDirecao += 360;

         EditMagnitude.Text := 'Magnitude: ' + IntToStr(magnitudes[X, Y]);
         EditDirecao.Text := 'Direção: ' +
                             FloatToStrF(magDirecao, ffFixed, 7, 2) + 'º';

       end;
  end
  else
  begin
    EditMagnitude.Text := 'Magnitude: -';
    EditDirecao.Text := 'Direção: -';
  end;
end;

procedure TForm1.Laplaciano8Click(Sender: TObject);
begin
  DesativarSobel;
  FiltroLaplaciano8;
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

// Botões de Arquivo.
procedure TForm1.AbrirClick(Sender: TObject);
begin
  if (OpenDialog1.Execute()) then Image1.Picture.LoadFromFile(OpenDialog1.Filename);
  // Reseta a Imagem 2 se ela estiver preenchida.
  if (Image2.Picture.Graphic <> nil) then Image2.Picture.Clear;

  DesativarSobel;

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

  EditMagnitude.Left := Button1.Left - EditMagnitude.Width +Button1.Width div 2;
  EditDirecao.Left := EditMagnitude.Left + EditMagnitude.Width;

  EditMagnitude.Top := Image1.Top + Image1.Top div 2;
  EditDirecao.Top := Image1.Top + Image1.Top div 2;

end;

procedure TForm1.SalvarClick(Sender: TObject);
begin
  SavePictureDialog1.DefaultExt := 'bmp';
  if (SavePictureDialog1.Execute()) then Image1.Picture.SaveToFile(SavePictureDialog1.FileName);
end;

procedure TForm1.SairClick(Sender: TObject);
begin
  close();
end;

end.

