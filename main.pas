unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  PriorityQueue = class
  private
    a:  array of Double;
    pr: array of Integer;
    ar: array of Integer;
    n: Integer;
    procedure swap(x, y: Integer);
    procedure siftDown(x: Integer);
    procedure siftUp(x: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure insert(p: Integer; v: Double);
    function  extract_min: Integer;
    procedure decrease_key(p: Integer; v: Double);
    function  empty: Boolean;
  end;
  Edge = record
    v: Integer;
    w: Double;
  end;

var
  Form1: TForm1;
  a: array of TPoint;
  e: array of array of Edge;
  d: array of Double;
  h: array of Double;
  used: array of Byte;
  go: array of Integer;
  marks:  array of Integer;
  ld: array of array of Double;
  count: Integer;

implementation

{$R *.dfm}

//*********************************************//

constructor PriorityQueue.Create;
const
  MAX_SIZE = 1000000;
begin
  n := 0;
  SetLength(a, MAX_SIZE);
  SetLength(ar, MAX_SIZE);
  SetLength(pr, MAX_SIZE);
end;

destructor PriorityQueue.Destroy;
begin
  SetLength(a, 0);
  SetLength(ar, 0);
  SetLength(pr, 0);
  inherited;
end;

procedure PriorityQueue.swap(x, y: Integer);
var
  t: Double;
  q: Integer;
begin
  t := a[x];
  a[x] := a[y];
  a[y] := t;
  q := ar[x];
  ar[x] := ar[y];
  ar[y] := q;
  q := pr[ar[x]];
  pr[ar[x]] := pr[ar[y]];
  pr[ar[y]] := q;
end;

procedure PriorityQueue.siftDown(x: Integer);
begin
  if 2 * x + 1 >= n then
    exit;
  if 2 * x + 2 = n then begin
    if a[2 * x + 1] < a[x] then
      swap(2 * x + 1, x);
    exit;
  end;
  if (a[2 * x + 1] <= a[2 * x + 2]) and (a[2 * x + 1] < a[x]) then begin
    swap(2 * x + 1, x);
    siftDown(2 * x + 1);
  end else if a[2 * x + 2] < a[x] then begin
    swap(2 * x + 2, x);
    siftDown(2 * x + 2);
  end;
end;

procedure PriorityQueue.siftUp(x: Integer);
begin
  if x = 0 then
    exit;
  if a[(x - 1) div 2] > a[x] then begin
    swap((x - 1) div 2, x);
    siftUp((x - 1) div 2);
    exit;
  end;
end;

procedure PriorityQueue.insert(p: Integer; v: Double);
begin
  a[n] := v;
  pr[p] := n;
  ar[n] := p;
  n := n + 1;
  siftUp(n - 1);
end;

function PriorityQueue.extract_min: Integer;
begin
  if n > 0 then begin
    result := ar[0];
    n := n - 1;
    swap(0, n);
    siftDown(0);
  end else
    result := -1;
end;

procedure PriorityQueue.decrease_key(p: Integer; v: Double);
var
  x: Integer;
begin
  x := pr[p];
  if x < n then begin
    if v > a[x] then begin
      a[x] := v;
      siftDown(x);
    end else begin
      a[x] := v;
      siftUp(x);
    end;
  end;
end;

function PriorityQueue.empty: Boolean;
begin
  result := n <= 0;
end;

//*********************************************//

function sqrdist(a, b: TPoint): Double;
begin
  result := sqr(a.x - b.x) + sqr(a.y - b.y);
end;

procedure Dijkstra(s, t: Integer; omnivertex: Boolean = false);
const
  INF: Double = 1/0;
var
  i, v: Integer;
  min: Double;
  flag: Boolean;
  queue: PriorityQueue;
begin
  SetLength(d, Length(a));
  for i := 0 to High(d) do
    d[i] := INF;
  d[s] := 0;

  SetLength(used, Length(a));
  for i := 0 to High(used) do
    used[i] := 0;
  used[s] := 1;

  queue := PriorityQueue.Create;
  queue.insert(s, 0);

  SetLength(go, Length(a));
  count := 0;
  while not queue.empty do begin

    v := queue.extract_min;

    if (v = t) and not omnivertex then
      break;

    used[v] := 2;
    Inc(count);

    for i := 0 to High(e[v]) do
      if used[e[v][i].v] <> 2 then begin
        if d[e[v][i].v] > d[v] + e[v][i].w then begin
          d[e[v][i].v] := d[v] + e[v][i].w;
          go[e[v][i].v] := v;
          if used[e[v][i].v] = 0 then
            queue.insert(e[v][i].v, d[e[v][i].v])
          else
            queue.decrease_key(e[v][i].v, d[e[v][i].v]);
        end;
        used[e[v][i].v] := 1;
      end;

  end;

  if not omnivertex then
    Form1.Caption := 'Vertexes seen: ' + IntToStr(count);

  queue.Destroy;

end;


procedure A_Star(s, t: Integer; omnivertex: Boolean = false);
const
  INF: Double = 1/0;
var
  i, v: Integer;
  min: Double;
  flag: Boolean;
  queue: PriorityQueue;
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
  used[s] := 1;

  queue := PriorityQueue.Create;
  queue.insert(s, 0);

  SetLength(go, Length(a));
  count := 0;
  while not queue.empty do begin

    v := queue.extract_min;

    if (v = t) and not omnivertex then
      break;

    used[v] := 2;
    Inc(count);

    for i := 0 to High(e[v]) do
      if used[e[v][i].v] <> 2 then begin
        if d[e[v][i].v] > d[v] - h[v] + h[e[v][i].v] + e[v][i].w then begin
          d[e[v][i].v] := d[v] - h[v] + h[e[v][i].v] + e[v][i].w;
          go[e[v][i].v] := v;
          if used[e[v][i].v] = 0 then
            queue.insert(e[v][i].v, d[e[v][i].v])
          else
            queue.decrease_key(e[v][i].v, d[e[v][i].v]);
        end;
        used[e[v][i].v] := 1;
      end;

  end;

  //if not omnivertex then
  //  Form1.Caption := 'Vertexes seen: ' + IntToStr(count);

  queue.Destroy;

end;

procedure ALT(s, t: Integer; omnivertex: Boolean = false);
const
  INF: Double = 1/0;
var
  i, j, v: Integer;
  min: Double;
  flag: Boolean;
  queue: PriorityQueue;
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
  used[s] := 1;

  queue := PriorityQueue.Create;
  queue.insert(s, 0);

  SetLength(go, Length(a));
  count := 0;
  while not queue.empty do begin

    v := queue.extract_min;

    if (v = t) and not omnivertex then
      break;

    used[v] := 2;
    Inc(count);

    for i := 0 to High(e[v]) do
      if used[e[v][i].v] <> 2 then begin
        if d[e[v][i].v] > d[v] - h[v] + h[e[v][i].v] + e[v][i].w then begin
          d[e[v][i].v] := d[v] - h[v] + h[e[v][i].v] + e[v][i].w;
          go[e[v][i].v] := v;
          if used[e[v][i].v] = 0 then
            queue.insert(e[v][i].v, d[e[v][i].v])
          else
            queue.decrease_key(e[v][i].v, d[e[v][i].v]);
        end;
        used[e[v][i].v] := 1;
      end;

  end;

  //if not omnivertex then
  //  Form1.Caption := 'Vertexes seen: ' + IntToStr(count);

  queue.Destroy;

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
  R = 0;
  R_LAND = 7;
  R_GREEN = 3;
  R_TARGET = 7;
  DRAW_PATH = true;
  TEST_COUNT = 1;
var
  i, j, u: Integer;
  deg_count: Integer;
  target: Integer;
  min: Double;
  min_id: Integer;
  mk: array of TPoint;
  N: Integer;
  time_stamp: Integer;
begin
  RandSeed := RAND_SEED;

  N := 12000;

  SetLength(a, N);
  for i := 0 to N - 1 do begin
      a[i].x := random(MAX_WIDTH - 2 * PADDING) + PADDING;
      a[i].y := random(MAX_HEIGHT - 2 * PADDING) + PADDING;
  end;

  SetLength(e, Length(a));
  for i := 0 to N - 1 do begin
    deg_count := 0;
    for j := 0 to N - 1 do
      if (i <> j) and (sqrdist(a[i], a[j]) < SQR_MAX_DIST) then begin
        SetLength(e[i], Length(e[i]) + 1);
        SetLength(e[j], Length(e[j]) + 1);
        e[i][High(e[i])].v := j;
        e[j][High(e[j])].v := i;
        e[i][High(e[i])].w := sqrt(sqrdist(a[i], a[j])) * ((1 + random) / 2 * MAX_DIST_DIFF + 1);
        e[j][High(e[j])].w := e[i][High(e[i])].w;
        Inc(deg_count);
        if deg_count >= MAX_COUNT then
          break;
      end;
  end;

  Image1.Canvas.Pen.Color := RGB(180, 180, 180);
  for i := 0 to N - 1 do
    for j := 0 to High(e[i]) do begin
      Image1.Canvas.MoveTo(a[i].x, a[i].y);
      Image1.Canvas.LineTo(a[e[i][j].v].x, a[e[i][j].v].y);
    end;
  Image1.Canvas.Pen.Color := clBlack;

  SetLength(marks, 13);
  SetLength(mk, Length(marks));
  mk[0] := Point(PADDING, PADDING + (MAX_HEIGHT - 2 * PADDING) div 4);
  mk[1] := Point(PADDING, PADDING + 2 * (MAX_HEIGHT - 2 * PADDING) div 4);
  mk[2] := Point(PADDING, PADDING + 3 * (MAX_HEIGHT - 2 * PADDING) div 4);
  mk[3] := Point(MAX_WIDTH - PADDING, PADDING + (MAX_HEIGHT - 2 * PADDING) div 4);
  mk[4] := Point(MAX_WIDTH - PADDING, PADDING + 2 * (MAX_HEIGHT - 2 * PADDING) div 4);
  mk[5] := Point(MAX_WIDTH - PADDING, PADDING + 3 * (MAX_HEIGHT - 2 * PADDING) div 4);
  mk[6] := Point(PADDING + (MAX_WIDTH - 2 * PADDING) div 4, PADDING);
  mk[7] := Point(PADDING + 2 * (MAX_WIDTH - 2 * PADDING) div 4, PADDING);
  mk[8] := Point(PADDING + 3 * (MAX_WIDTH - 2 * PADDING) div 4, PADDING);
  mk[9] := Point(PADDING + (MAX_WIDTH - 2 * PADDING) div 4, MAX_HEIGHT - PADDING);
  mk[10] := Point(PADDING + 2 * (MAX_WIDTH - 2 * PADDING) div 4, MAX_HEIGHT - PADDING);
  mk[11] := Point(PADDING + 3 * (MAX_WIDTH - 2 * PADDING) div 4, MAX_HEIGHT - PADDING);
  mk[12] := Point(MAX_WIDTH div 2, MAX_HEIGHT div 2);

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

  time_stamp := GetTickCount;
  for i := 1 to TEST_COUNT do begin
    //Dijkstra(0, target);
    //A_Star(0, target);
    ALT(0, target);
  end;
  if TEST_COUNT > 0 then
    Caption := 'Vertexed seen: ' + IntToStr(count) + ', time elapsed: ' + FloatToStr((GetTickCount - time_stamp) / TEST_COUNT) + ' ms';

  for i := 0 to N - 1 do begin
    if (i = target) or (i = 0) then begin
      Image1.Canvas.Brush.Color := clRed;
      Image1.Canvas.Ellipse(a[i].x - R_TARGET, a[i].y - R_TARGET, a[i].x + R_TARGET, a[i].y + R_TARGET);
    end else if used[i] = 2 then begin
      Image1.Canvas.Brush.Color := RGB(0, 230, 0);
      Image1.Canvas.Ellipse(a[i].x - R_GREEN, a[i].y - R_GREEN, a[i].x + R_GREEN, a[i].y + R_GREEN);
    end else if R > 0 then begin
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

function GenerateTown(N, x, y, r, s: Integer): Integer;
const
  RAND_DIFF = 0.1;
var
  i: Integer;
  l: Double;
  sin_a, cos_a, alpha: Double;
begin

  // Main street
  alpha := pi * random;
  cos_a := cos(alpha);
  sin_a := sin(alpha);
  l := 2 * r / s;
  SetLength(a, Length(a) + s);
  SetLength(e, Length(a));
  a[N] := Point(Round(x - r * cos_a), Round(y - r * sin_a));
  for i := 1 to s - 1 do begin
    a[N + i] := Point(a[N + i - 1].x + Round(l * cos_a * (1 + (1 + random) / 2 * RAND_DIFF)), a[N + i - 1].y + Round(l * sin_a * (1 + (1 + random) / 2 * RAND_DIFF)));
    SetLength(e[N + i], Length(e[N + i]) + 1);
    e[N + i][High(e[N + i])].v := N + i - 1;
    e[N + i][High(e[N + i])].w := sqrt(sqrdist(a[N + i], a[N + i - 1]));
    SetLength(e[N + i - 1], Length(e[N + i - 1]) + 1);
    e[N + i - 1][High(e[N + i - 1])].v := N + i;
    e[N + i - 1][High(e[N + i - 1])].w := sqrt(sqrdist(a[N + i], a[N + i - 1]));
  end;

  result := N + s;

end;

procedure TForm1.Button2Click(Sender: TObject);
const
  MAX_WIDTH = 1353;
  MAX_HEIGHT = 633;
  PADDING = 10;
  SQR_MAX_DIST = sqr(10);
  MAX_DIST_DIFF = 0.1;
  MAX_COUNT = 5;
  RAND_SEED = 100;
  INF: Double = 1/0;
  R = 0;
  R_LAND = 7;
  R_GREEN = 3;
  R_TARGET = 7;
  DRAW_PATH = false;
  TEST_COUNT = 0;
var
  i, j, u: Integer;
  deg_count: Integer;
  target: Integer;
  min: Double;
  min_id: Integer;
  mk: array of TPoint;
  N: Integer;
  time_stamp: Integer;
begin
  RandSeed := RAND_SEED;
  N := 0;

  N := N + GenerateTown(N, 300, 300, 100, 20);

  Image1.Canvas.Pen.Color := RGB(180, 180, 180);
  for i := 0 to N - 1 do
    for j := 0 to High(e[i]) do begin
      Image1.Canvas.MoveTo(a[i].x, a[i].y);
      Image1.Canvas.LineTo(a[e[i][j].v].x, a[e[i][j].v].y);
    end;
  Image1.Canvas.Pen.Color := clBlack;

end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  Button2.SetFocus;
end;

end.
