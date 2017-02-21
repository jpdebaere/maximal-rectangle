unit MaximalRectangle.Queue;

{********************************************************************}
{ TMaximalRectangleQueue                                             }
{ An implementation of a queue to support the operations of the      }
{ maximal rectangle class.                                           }
{                                                                    }
{ Written by                                                         }
{   Misel Krstovic                                                   }
{   copyright © 1999-2011                                            }
{                                                                    }
{ The source code is given as is. The author is not responsible      }
{ for any possible damage done due to the use of this code.          }
{ The class can be freely used in any application. The source        }
{ code remains property of the writer and may not be distributed     }
{ freely as such.                                                    }
{********************************************************************}

interface

uses
  SysUtils, Classes, Types;

const
  QueueMaxSize = High(Cardinal);

type
  EQueueEmpty = class(Exception);
  EQueueFull  = class(Exception);
  EQueueNotInitialized = class(Exception);
  EQueueTypeNotDefined = class(Exception);

  QueueNext = ^QueueNode;
  QueueNode  = record
    Num  : Integer;
    Data : TObject;
    Next : QueueNext;
  end;

  TMaximalRectangleQueue = class
  Private
    _Front  : QueueNext;
    _Rear   : QueueNext;
    _Count : Cardinal;  // 4,294,967,295 = 4GB (unsigned 32-bit)
    function _GetCount : Word;
  public
    property Count: Word read _GetCount;
    procedure Clear;
    procedure Enqueue(Buffer : Integer; Data : TObject);
    function Dequeue : TObject;
    function DequeueMaxQuality : TObject;
    function Peek : TObject;
    function IsEmpty : boolean;
    function IsFull  : boolean;

    procedure Free;
    constructor Create;
    destructor  Destroy; Override;
  end;

var
  TempNode : QueueNext;

implementation

procedure TMaximalRectangleQueue.Free;
begin
  // Destroys an object and frees its associated memory, if necessary.
  If Self<>nil then Self.Destroy;
end;

constructor TMaximalRectangleQueue.Create;
begin
  // Set number of nodes to zero
  _Count := 0;

  // Set both ends to nil
  _Front := nil;
  _Rear  := nil;
end;

destructor TMaximalRectangleQueue.Destroy;
begin
  Clear; // Do self cleanup
  inherited Destroy;
end;

procedure TMaximalRectangleQueue.Clear;
var
  TempNode : QueueNext;
begin
  If _Count=0 then exit;

  // Dispose of all nodes between _Front & _Rear
  Repeat
    TempNode := _Front;
    _Front := _Front^.Next;
    if TempNode.Data<>nil then begin
      TempNode.Data.Free;
      TempNode.Data := nil;
    end;
    Dispose(TempNode);
    _Count := _Count - 1;
  until IsEmpty=true;

  // Clear counter
  _Count := 0;

  // Set both ends to nil
  _Front := nil;
  _Rear  := nil;
end;

procedure TMaximalRectangleQueue.Enqueue(Buffer : Integer; Data : TObject);
begin
  If IsFull=true then
    raise EQueueFull.Create('Queue is full (max='+inttostr(QueueMaxSize)+')')
  else begin
    // Perform insertion
    If _Count = 0 then begin
      New(_Rear);
      _Front := _Rear;
    end else begin
      New(_Rear^.Next);
      _Rear := _Rear^.Next;
    end;
    _Rear^.Num := Buffer;
    _Rear^.Data := Data;
    _Count := _Count + 1;
  end;

  _Rear^.Next := nil; // Do not remove this line. All heck will break loose!
end;

function TMaximalRectangleQueue.Dequeue : TObject;
var
  TempNode : QueueNext;
begin
  If IsEmpty=true then
    raise EQueueEmpty.Create('Queue is empty')
  else begin
    TempNode := _Front;
    result := _Front^.Data;
    _Front := _Front^.Next;
    Dispose(TempNode);

    _Count := _Count - 1;
  end;
end;

function TMaximalRectangleQueue.DequeueMaxQuality : TObject;
var
  Head : QueueNext;
  i    : LongWord;
  LargestQualityNode,
  LargestQualityPrevNode,
  PrevHead,
  TempNode : QueueNext;
  LargestQuality,
  CurrentQuality : Integer;
begin
  LargestQuality := -1;
  LargestQualityNode := nil;
  LargestQualityPrevNode := nil;

  If IsEmpty=true then
    raise EQueueEmpty.Create('Queue is empty')
  else begin
    head := _Front;
    PrevHead := nil;
    i := 1; // Sanity limits!
    While (Head<>nil) do begin
      if i>QueueMaxSize then begin
        result := nil;
        exit;
      end;
      CurrentQuality := Head^.Num;
      If CurrentQuality>LargestQuality then begin
        LargestQuality := CurrentQuality;
        LargestQualityNode := Head;
        LargestQualityPrevNode := PrevHead;
      end;
      PrevHead := Head;
      Head := Head^.Next;
      inc(i);
    end;

    // Move the maximum node to the front
    If LargestQualityNode=_front then begin
      result := Dequeue;
    end else if LargestQualityNode=_Rear then begin
      TempNode := LargestQualityNode;
      result := TempNode^.Data;
      _Rear := LargestQualityPrevNode;
      _Rear^.Next := nil;
      Dispose(TempNode);

      _Count := _Count - 1;
    end else begin
      TempNode := LargestQualityNode;
      result := TempNode^.Data;
      LargestQualityPrevNode^.Next := TempNode^.Next;
      Dispose(TempNode);

      _Count := _Count - 1;
    end;
  end;
end;

function TMaximalRectangleQueue.Peek : TObject;
begin
  If IsEmpty=true then
    raise EQueueEmpty.Create('Queue is empty')
  else begin
    result := _Front^.Data;
  end;
end;

function TMaximalRectangleQueue.IsEmpty : boolean;
begin
  If _Count=0 then result:= true
  else result := false;
end;

function TMaximalRectangleQueue.IsFull : boolean;
begin
  If _Count=QueueMaxSize then result := true
  else result := false;
end;

function TMaximalRectangleQueue._GetCount : Word;
begin
  result := _Count;
end;

end.

