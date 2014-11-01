unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  a: array of TPoint;
  m: array of array of Double;
  d: array of Double;
  h: array of Double;
  used: array of Byte;
  go: array of Integer;
  marks:  array of Integer;
  ld: array of array of Double;

implementation

{$R *.dfm}

function sqrdist(a, b: TPoint): Double;
begin
  result := sqr(a.x - b.x) + sqr(a.y - b.y);
end;

procedure Dijkstra(s, t: Integer; omnivertex: Boolean = false);
const
  INF: Double = 1/0;
var
  i, v, count: Integer;
  min: Double;
  flag: Boolean;
begin
  SetLength(d, Length(a));
  for i := 0 to High(d) do
    d[i] := INF;
  d[s] := 0;

  SetLength(used, Length(a));
  for i := 0 to High(used) do
    used[i] := 0;
  used[s] := 1;

  SetLength(go, Length(a));
  count := 0;
  while true do begin

    flag := false;
    min := INF;

    for i := 0 to High(a) do
      if used[i] = 1 then
        if d[i] < min then begin
          min := d[i];
          v := i;
          flag := true;
        end;

    if not flag then
      break;

    if (v = t) and not omnivertex then
      break;

    used[v] := 2;
    Inc(count);

    for i := 0 to High(a) do
      if m[v][i] < INF then
        if used[i] <> 2 then begin
          if d[i] > d[v] + m[v][i] then begin
            d[i] := d[v] + m[v][i];
            go[i] := v;
          end;
          used[i] := 1;
        end;

  end;

  if not omnivertex then
    Form1.Caption := 'Vertexes seen: ' + IntToStr(count);

end;

procedure A_Star(s, t: Integer);
const
  INF: Double = 1/0 ;
var
  i, v, count: Integer;
  min: Double;
  flag: Boolean;
begin
  SetLength(d, Length(a));
  for i := 0 to High(d) do
    d[i] := INF;
  d[s] := 0;

  SetLength(h, Length(a));
  for i := 0 to High(h) do
    h[i] := sqrt(sqrdist(a[i], a[t]));

  SetLength(used, Length(a));
  for i := 0 to High(used) do
    used[i] := 0;
  used[0] := 1;

  SetLength(go, Length(a));
  count := 0;
  while true do begin

    flag := false;
    min := INF;

    for i := 0 to High(a) do
      if used[i] = 1 then
        if d[i] < min then begin
          min := d[i];
          v := i;
          flag := true;
        end;

    if not flag then
      break;

    if v = t then
      break;

    used[v] := 2;
    Inc(count);

    for i := 0 to High(a) do
      if m[v][i] < INF then
        if used[i] <> 2 then begin
          if d[i] > d[v] - h[v] + h[i] + m[v][i] then begin
            d[i] := d[v] - h[v] + h[i] + m[v][i];
            go[i] := v;
          end;
          used[i] := 1;
        end;

  end;

  Form1.Caption := 'Vertexes seen: ' + IntToStr(count);

end;

function d_abs(x: Double): Double;
begin
  if x >= 0 then
    result := x
  else
    result := -x;
end;

procedure ALT(s, t: Integer);
const
  INF: Double = 1/0 ;
var
  i, j, v, count: Integer;
  min: Double;
  flag: Boolean;
begin
  SetLength(d, Length(a));
  for i := 0 to High(d) do
    d[i] := INF;
  d[s] := 0;

  SetLength(h, Length(a));
  for i := 0 to High(h) do begin
    h[i] := sqrt(sqrdist(a[i], a[t]));
    for j := 0 to High(marks) do
      if (ld[j][t] <> INF) and (ld[j][i] <> INF) then
        if h[i] < abs(ld[j][t] - ld[j][i]) then
          h[i] := abs(ld[j][t] - ld[j][i]);
  end;

  SetLength(used, Length(a));
  for i := 0 to High(used) do
    used[i] := 0;
  used[0] := 1;

  SetLength(go, Length(a));
  count := 0;
  while true do begin

    flag := false;
    min := INF;

    for i := 0 to High(a) do
      if used[i] = 1 then
        if d[i] < min then begin
          min := d[i];
          v := i;
          flag := true;
        end;

    if not flag then
      break;

    if v = t then
      break;

    used[v] := 2;
    Inc(count);

    for i := 0 to High(a) do
      if m[v][i] < INF then
        if used[i] <> 2 then begin
          if d[i] > d[v] - h[v] + h[i] + m[v][i] then begin
            d[i] := d[v] - h[v] + h[i] + m[v][i];
            go[i] := v;
          end;
          used[i] := 1;
        end;

  end;

  Form1.Caption := 'Vertexes seen: ' + IntToStr(count);

end;

procedure ALT_Preprocessing();
var
  i, j: Integer;
begin
  SetLength(ld, Length(marks), Length(a));
  for i := 0 to High(marks) do begin
    Form1.Caption := Form1.Caption + ' ' + IntToStr(i);
    Dijkstra(marks[i], 10, true);
    //Form1.Caption := Form1.Caption + ' ' + IntToStr(Round(d[10]));
    for j := 0 to High(d) do
      ld[i][j] := d[j];
  end;
end;

function Point(x, y: Integer): TPoint;
begin
  result.x := x;
  result.y := y;
end;

procedure TForm1.Button1Click(Sender: TObject);
const
  MAX_WIDTH = 1353;
  MAX_HEIGHT = 633;
  PADDING = 10;
  SQR_MAX_DIST = sqr(14);
  MAX_DIST_DIFF = 0.1;
  MAX_COUNT = 5;
  RAND_SEED = 100;
  INF: Double = 1/0;
  R = 2;
  R_LAND = 7;
  R_GREEN = 3;
  DRAW_PATH = true;
var
  i, j, u: Integer;
  count: Integer;
  target: Integer;
  min: Double;
  min_id: Integer;
  mk: array of TPoint;
  N: Integer;
begin
  RandSeed := RAND_SEED;

  N := 12000;

  SetLength(a, N);
  for i := 0 to N - 1 do begin
      a[i].x := random(MAX_WIDTH - 2 * PADDING) + PADDING;
      a[i].y := random(MAX_HEIGHT - 2 * PADDING) + PADDING;
  end;

  SetLength(m, N, N);
  for i := 0 to N - 1 do
    for j := 0 to N - 1 do
      m[i][j] := INF;

  for i := 0 to N - 1 do begin
    count := 0;
    for j := 0 to N - 1 do
      if (i <> j) and (sqrdist(a[i], a[j]) < SQR_MAX_DIST) then begin
        m[i][j] := sqrt(sqrdist(a[i], a[j])) * (random * MAX_DIST_DIFF + 1);
        m[j][i] := m[i][j];
        Inc(count);
        if count >= MAX_COUNT then
          break;
      end;
  end;

  Image1.Canvas.Pen.Color := RGB(180, 180, 180);
  for i := 0 to N - 1 do
    for j := i + 1 to N - 1 do
      if m[i][j] < INF then begin
        Image1.Canvas.MoveTo(a[i].x, a[i].y);
        Image1.Canvas.LineTo(a[j].x, a[j].y);
      end;
  Image1.Canvas.Pen.Color := clBlack;

  SetLength(marks, 9);
  SetLength(mk, Length(marks));
  mk[0] := Point(PADDING, PADDING + (MAX_HEIGHT - 2 * PADDING) div 3);
  mk[1] := Point(PADDING, PADDING + 2 * (MAX_HEIGHT - 2 * PADDING) div 3);
  mk[2] := Point(MAX_WIDTH - PADDING, PADDING + (MAX_HEIGHT - 2 * PADDING) div 3);
  mk[3] := Point(MAX_WIDTH - PADDING, PADDING + 2 * (MAX_HEIGHT - 2 * PADDING) div 3);
  mk[4] := Point(PADDING + (MAX_WIDTH - 2 * PADDING) div 3, PADDING);
  mk[5] := Point(PADDING + 2 * (MAX_WIDTH - 2 * PADDING) div 3, PADDING);
  mk[6] := Point(PADDING + (MAX_WIDTH - 2 * PADDING) div 3, MAX_HEIGHT - PADDING);
  mk[7] := Point(PADDING + 2 * (MAX_WIDTH - 2 * PADDING) div 3, MAX_HEIGHT - PADDING);
  mk[8] := Point(MAX_WIDTH div 2, MAX_HEIGHT div 2);

  for i := 0 to High(marks) do begin
    min := INF;
    min_id := 0;
    for j := 0 to High(a) do
      if abs(a[j].x - mk[i].x) + abs(a[j].y - mk[i].y) < min then begin
        min := abs(a[j].x - mk[i].x) + abs(a[j].y - mk[i].y);
        min_id := j;
      end;
    marks[i] := min_id;
  end;

  target := 100;
  for j := 0 to High(a) do
    if (abs(a[j].x - MAX_WIDTH + PADDING) < 20) and (abs(a[j].y - PADDING) < 20) then begin
      target := j;
      break;
    end;

  ALT_Preprocessing();

  SetLength(go, Length(a));
  SetLength(used, Length(a));

  go[target] := target;

  //Dijkstra(0, target);
  //A_Star(0, target);
  ALT(0, target);

  for i := 0 to N - 1 do begin
    if (i = target) or (i = 0) then begin
      Image1.Canvas.Brush.Color := clRed;
      Image1.Canvas.Ellipse(a[i].x - R, a[i].y - R, a[i].x + R, a[i].y + R);
    end else if used[i] = 2 then begin
      Image1.Canvas.Brush.Color := RGB(0, 230, 0);
      Image1.Canvas.Ellipse(a[i].x - R_GREEN, a[i].y - R_GREEN, a[i].x + R_GREEN, a[i].y + R_GREEN);
    end else begin
      Image1.Canvas.Brush.Color := clWhite;
      Image1.Canvas.Ellipse(a[i].x - R, a[i].y - R, a[i].x + R, a[i].y + R);
    end;

  end;

  Image1.Canvas.Brush.Color := clYellow;
  for i := 0 to High(marks) do begin
    Image1.Canvas.Ellipse(a[marks[i]].x - R_LAND, a[marks[i]].y - R_LAND, a[marks[i]].x + R_LAND, a[marks[i]].y + R_LAND);
  end;

  Image1.Canvas.Pen.Width := 3;

  Image1.Canvas.MoveTo(Round(a[target].x), Round(a[target].y));
  u := go[target];
  while true and DRAW_PATH do begin

    Image1.Canvas.LineTo(Round(a[u].x), Round(a[u].y));
    if (u = 0) or (u = target) then
      break;
    u := go[u];

  end;

  Image1.Canvas.Pen.Width := 1;

end;

end.
