unit uZoom;

interface

uses
  ExtCtrls, Math;

var
  ZoomFactor: Double = 1.0;

procedure AplicarZoom(Img1, Img2: TImage; BaseWidth, BaseHeight: Integer);
procedure AplicarZoomIn(Img1, Img2: TImage; BaseWidth, BaseHeight: Integer);
procedure AplicarZoomOut(Img1, Img2: TImage; BaseWidth, BaseHeight: Integer);
procedure ResetarZoom(Img1, Img2: TImage; BaseWidth, BaseHeight: Integer);
function ConverterX(X: Integer): Integer;
function ConverterY(Y: Integer): Integer;

implementation

procedure AplicarZoom(Img1, Img2: TImage; BaseWidth, BaseHeight: Integer);
begin
  Img1.Width := Round(BaseWidth * ZoomFactor);
  Img1.Height := Round(BaseHeight * ZoomFactor);
  
  Img2.Width := Round(BaseWidth * ZoomFactor);
  Img2.Height := Round(BaseHeight * ZoomFactor);
end;

procedure AplicarZoomIn(Img1, Img2: TImage; BaseWidth, BaseHeight: Integer);
begin
  ZoomFactor := ZoomFactor + 0.2;
  if ZoomFactor > 10.0 then ZoomFactor := 10.0; // Limite máximo de zoom (10x)
  AplicarZoom(Img1, Img2, BaseWidth, BaseHeight);
end;

procedure AplicarZoomOut(Img1, Img2: TImage; BaseWidth, BaseHeight: Integer);
begin
  ZoomFactor := ZoomFactor - 0.2;
  if ZoomFactor < 0.1 then ZoomFactor := 0.1; // Limite mínimo de zoom (0.1x)
  AplicarZoom(Img1, Img2, BaseWidth, BaseHeight);
end;

procedure ResetarZoom(Img1, Img2: TImage; BaseWidth, BaseHeight: Integer);
begin
  ZoomFactor := 1.0;
  AplicarZoom(Img1, Img2, BaseWidth, BaseHeight);
end;

function ConverterX(X: Integer): Integer;
begin
  Result := Round(X / ZoomFactor);
end;

function ConverterY(Y: Integer): Integer;
begin
  Result := Round(Y / ZoomFactor);
end;

end.
