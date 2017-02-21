unit MaximalRectangle;

{********************************************************************}
{ TMaximalRectangle                                                  }
{ An implementation based on a paper from Xerox on solving the       }
{ maximal white space problem                                        }
{                                                                    }
{ Written by                                                         }
{   Misel Krstovic                                                   }
{   copyright © 2007-2011, 2017                                      }
{                                                                    }
{ Thanks to                                                          }
{   Mohammed Ismail                                                  }
{                                                                    }
{ The source code is given as is. The author is not responsible      }
{ for any possible damage done due to the use of this code.          }
{ The class can be freely used in any application. The source        }
{ code remains property of the writer and may not be distributed     }
{ freely as such.                                                    }
{********************************************************************}

interface

uses
  Types, SysUtils, MaximalREctangle.Queue;

type
  TPivot = TRect;

  TRectangles = array of TRect;

  TQueueNode = class
  private
    _Q         : Integer;
    _R         : TRect;
    _Obstacles : TRectangles;
  public
    property Q : Integer read _Q;
    property R : TRect read _R;
    property Obstacles : TRectangles read _Obstacles;
    constructor Create(Quality : Integer; Rectangle : TRect; Obstacles : TRectangles);
  end;

  TMaximalRectangle = class
  private
    _Bound     : TRect;
    _Obstacles : TRectangles;

    function Overlaps(U, R: TRect): boolean;
    function Pick(Bound : TRect; Obstacles: TRectangles): TPivot;
    function Quality(Rectangle: TRect): Integer;
    function NotOverlaps(u : TRectangles; r : TRect) : TRectangles;
    function ClipObstacles(Bound : TRect; Obstacles : TRectangles; Protect : Boolean = false) : TRectangles;
    function GetObstaclesCount: Integer;
    function _GetMaxWhitespace: TRect;
  public
    constructor Create; overload;
    constructor Create(Bound : TRect); overload;
    destructor Destroy; override;
    property Count: Integer read GetObstaclesCount;
    property Obstacles: TRectangles read _Obstacles;
    procedure SetBound(Bound : TRect);
    procedure AddObstacle(Obstacle : TRect);
    procedure ClearObstacles;
    function GetMaxWhitespace(var MaxRect: TRect): Boolean;
  end;

implementation

uses Math;

function PointInRect(const Rect: TRect; const P: TPoint): Boolean;
begin
  Result := (P.X >= Rect.Left) and (P.X <= Rect.Right) and (P.Y >= Rect.Top)
    and (P.Y <= Rect.Bottom);
end;

function TMaximalRectangle.Overlaps(U, R: TRect): boolean;
begin
  result :=
  PointInRect(R, Point(U.Left, U.Top)) or
  PointInRect(R, Point(U.Right, U.Top)) or
  PointInRect(R, Point(U.Left, U.Bottom)) or
  PointInRect(R, Point(U.Right, U.Bottom));

  if not(result) then begin
    result :=
    PointInRect(U, Point(R.Left, R.Top)) or
    PointInRect(U, Point(R.Right, R.Top)) or
    PointInRect(U, Point(R.Left, R.Bottom)) or
    PointInRect(U, Point(R.Right, R.Bottom));
  end;
end;

function TMaximalRectangle.Quality(Rectangle: TRect): Integer;
begin
  result := abs((Rectangle.Right - Rectangle.Left) * (Rectangle.Bottom - Rectangle.Top));
end;

procedure TMaximalRectangle.SetBound(Bound: TRect);
begin
  _Bound := Bound; // Setting bound (Rb)
end;

function TMaximalRectangle.Pick(Bound : TRect; Obstacles: TRectangles): TPivot;
var
  i,
  bound_mid_x,
  bound_mid_y,
  obstcl_mid_x,
  obstcl_mid_y,
  best_distance,
  distance : integer;
begin
  best_distance := MAXINT;

  bound_mid_x := Bound.Right - Bound.Left;
  bound_mid_y := Bound.Bottom - Bound.Top;

  // Enumerate throughout the rectangles and find the one
  // closer to the center of the _Bound_.
  for i:=0 to length(Obstacles)-1 do begin
    obstcl_mid_x := Obstacles[i].Right - Obstacles[i].Left;
    obstcl_mid_y := Obstacles[i].Bottom - Obstacles[i].Top;

    distance := floor(sqrt(power((obstcl_mid_x - bound_mid_x),2)+power((obstcl_mid_y - bound_mid_y),2)));
    if distance<best_distance then begin
      best_distance := distance;
      result := Obstacles[i];
    end;
  end;
end;

function TMaximalRectangle.NotOverlaps(u : TRectangles; r : TRect) : TRectangles;
var
  i : integer;
begin
  setlength(result, 0);
  for i := 0 to length(u)-1 do begin
    if not overlaps(u[i], r) then begin
      setlength(result, length(result)+1);
      result[length(result)-1] := u[i];
    end;
  end;
end;

procedure TMaximalRectangle.AddObstacle(Obstacle: TRect);
begin
  if Quality(Obstacle)>0 then begin
    SetLength(_Obstacles, Length(_Obstacles)+1);
    _Obstacles[Length(_Obstacles)-1] := Obstacle;
  end;
end;

procedure TMaximalRectangle.ClearObstacles;
begin
  SetLength(_Obstacles, 0);
end;

procedure DeleteX(var A : TRectangles; Index : Integer);
var
  Alength : Integer;
  i       : Integer;
begin
  // Code based on work by Rob Kennedy
  ALength := Length(A);
  if (ALength > 0) then begin
    if (Index < ALength) then begin
      for i := Index + 1 to ALength - 1 do
        A[i - 1] := A[i];
      SetLength(A, ALength - 1);
    end;
  end;
end;

function TMaximalRectangle.ClipObstacles(Bound : TRect; Obstacles : TRectangles; Protect : Boolean = false) : TRectangles;
var
  i : integer;
begin
  If Length(Obstacles)=0 then begin
    result := Obstacles;
    exit;
  end;

  for i := length(Obstacles)-1 downto 0 do begin
    if Overlaps(Bound, Obstacles[i]) then begin

      // Perform obstacle clipping
      If Obstacles[i].Left < Bound.Left then Obstacles[i].Left := Bound.Left;
      If Obstacles[i].top  < Bound.top  then Obstacles[i].top  := Bound.top;
      If Obstacles[i].Right  > Bound.Right  then Obstacles[i].Right  := Bound.Right;
      If Obstacles[i].Bottom > Bound.Bottom then Obstacles[i].Bottom := Bound.Bottom;

      if not protect then begin
        if (Obstacles[i].Left=Obstacles[i].Right) or
           (Obstacles[i].Top=Obstacles[i].Bottom) then begin
          // Removed due to being a line');
          DeleteX(Obstacles, i);
         end;
      end;
    end else begin
      // Non-overlapped obstacle
      if not protect then begin
        // Removed due to not overlapping
        DeleteX(Obstacles, i);
      end;
    end;
  end;
  Result := Obstacles;
end;

constructor TMaximalRectangle.Create(Bound: TRect);
begin
  Create;
  SetBound(Bound);
end;

constructor TMaximalRectangle.Create;
begin
  SetLength(_Obstacles, 0);
end;

destructor TMaximalRectangle.Destroy;
begin
  inherited;
end;

function TMaximalRectangle.GetMaxWhitespace(var MaxRect: TRect): Boolean;
var
  i : integer;
begin
  if Count>0 then begin
    for i := 0 to Count - 1 do begin
      _Bound := _GetMaxWhitespace;
    end;
  end;
  MaxRect := _Bound;

  result := not(MaxRect.IsEmpty);
end;

function TMaximalRectangle._GetMaxWhitespace: TRect;
var
  Queue     : TMaximalRectangleQueue;
  QueueNode,
  QueueNode2 : TQueueNode;
  sub_q : Integer;
  sub_r : TRect;
  sub_obstacles,
  subrectangles : TRectangles;
  pivot : TPivot;
  i     : integer;

  PanicCount : Integer;
begin
  // Clipping obstacles that extend outside the 'bound' Rb
  _Obstacles := ClipObstacles(_Bound, _Obstacles);

  // Checking if an obstacle is filling the whole bound
  for i := 0 to Length(_Obstacles) - 1 do begin
    if EqualRect(_Bound, _Obstacles[i]) then begin
      result := Rect(0, 0, 0, 0);
      exit;
    end;
  end;

  Queue := TMaximalRectangleQueue.Create;
  try
    // ******************************************************
    // *** queue.enqueue(quality(bound),bound,rectangles) ***
    // ******************************************************
    QueueNode := TQueueNode.Create(Quality(_Bound), _Bound, _Obstacles);
    Queue.Enqueue(QueueNode.Q, QueueNode); // Pushing bounding box in queue

    // **********************************
    // *** while not queue.is_empty() ***
    // **********************************
    PanicCount := 0;
    while not Queue.IsEmpty do begin
      // *********************************************
      // *** (q,r,obstacles) = queue.dequeue_max() ***
      // *********************************************
      QueueNode := TQueueNode(Queue.DequeueMaxQuality); // Dequeue

      // **********************************
      // *** if obstacles==[]: return r ***
      // **********************************
      if length(QueueNode.Obstacles)=0 then begin
        result := QueueNode.R;
        QueueNode.Free; // No longer required
        exit; // Exiting due to obstacles exaustion
      end;

      // *******************************
      // *** pivot = pick(obstacles) ***
      // *******************************
      pivot := Pick(QueueNode.R, QueueNode.Obstacles); // Pivot is

      // **************************************
      // *** r0 = (pivot.x1,r.y0,r.x1,r.y1) ***
      // *** r1 = (r.x0,r.y0,pivot.x0,r.y1) ***
      // *** r2 = (r.x0,pivot.y1,r.x1,r.y1) ***
      // *** r3 = (r.x0,r.y0,r.x1,pivot.y0) ***
      // *** subrectangles = [r0,r1,r2,r3]  ***
      // **************************************
      SetLength(subrectangles, 4);
      subrectangles[0] := rect(Pivot.Right, QueueNode.R.Top, QueueNode.R.Right, QueueNode.R.Bottom);
      subrectangles[1] := rect(QueueNode.R.Left, QueueNode.R.Top, Pivot.Left, QueueNode.R.Bottom);
      subrectangles[2] := rect(QueueNode.R.Left, pivot.Bottom, QueueNode.R.Right, QueueNode.R.Bottom);
      subrectangles[3] := rect(QueueNode.R.Left, QueueNode.R.Top, QueueNode.R.Right, pivot.Top);
      subrectangles := ClipObstacles(_Bound, subrectangles, true);

      // ****************************************************
      //      for sub_r in subrectangles:
      //        sub_q = quality(sub_r)
      //        sub_obstacles = [list of u in obstacles if not overlaps(u,sub_r)]
      //        queue.enqueue(sub_q,sub_r,sub_obstacles)
      // ****************************************************
      for i := 0 to 3 do begin
        sub_r := subrectangles[i];
        sub_q := Quality(sub_r);
        // *************************************************************************
        // *** sub_obstacles = [list of u in obstacles if not overlaps(u,sub_r)] ***
        // *************************************************************************
        sub_obstacles := NotOverlaps(QueueNode.Obstacles ,sub_r);

        QueueNode2 := TQueueNode.Create(sub_q, sub_r, sub_obstacles);
        Queue.Enqueue(QueueNode2.Q, QueueNode2); // Enqueue
      end;
      QueueNode.Free;

      Inc(PanicCount);
      if PanicCount>3 then break;
    end;
    // Normal exit
  finally
    Queue.Free;
  end;
end;

function TMaximalRectangle.GetObstaclesCount: Integer;
begin
  result := length(_Obstacles);
end;

{ TQueueNode }

constructor TQueueNode.Create(Quality : Integer; Rectangle : TRect; Obstacles : TRectangles);
begin
  _Q := Quality;
  _R := Rectangle;
  _Obstacles := Obstacles;
end;

end.
