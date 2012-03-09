unit TestgCore;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework, gCore, System.Rtti;

type
  // Test methods for class TgBase

  ///	<summary>
  ///	  This is a example structure which will automaticly limit all
  ///	  assignements to the first 5 characters of the text
  ///	</summary>
  TgString5 = record
  strict private
    FValue: String;
  public
    function GetValue: String;
    procedure SetValue(const AValue: String);
    class operator implicit(AValue: Variant): TgString5; overload;
    class operator Implicit(AValue: TgString5): Variant; overload;
    property Value: String read GetValue write SetValue;
  end;

  ValidatePhone = class(Validation)
  public
    procedure Execute(AObject: TgObject; ARTTIProperty: TRttiProperty); override;
  end;

  ///	<summary>
  ///	  This is a example which should automaticly format any value assigned
  ///	  into a phone number
  ///	</summary>
  [ValidatePhone]
  TPhoneString = record
  strict private
    FValue: String;
  public
    function FormatPhone(AValue : String): String;
    function GetValue: String;
    procedure SetValue(const AValue: String);
    class operator Implicit(AValue: TPhoneString): Variant; overload;
    class operator Implicit(AValue: Variant): TPhoneString; overload;
    property Value: String read GetValue write SetValue;
  end;

  TBase2 = class(TgObject)
  strict private
    FIntegerProperty: Integer;
    FStringProperty: TgString5;
  published
    [DefaultValue(2)]
    property IntegerProperty: Integer read FIntegerProperty write FIntegerProperty;
    [DefaultValue('12345')]
    property StringProperty: TgString5 read FStringProperty write FStringProperty;
  End;

  TBase3 = Class(TBase2)
  End;

  TBase2List = Class(TgList<TBase2>)
  End;

  TBase = class(TgObject)
  strict private
    FBooleanProperty: Boolean;
    FDateProperty: TDate;
    FDateTimeProperty: TDateTime;
    FIntegerProperty: Integer;
    FManuallyConstructedObjectProperty: TBase;
    FObjectProperty: TBase2;
    FPhone: TPhoneString;
    FString5: TgString5;
    FStringProperty: String;
    FUnconstructedObjectProperty: TgBase;
    FUnreadableIntegerProperty: Integer;
    FUnwriteableIntegerProperty: Integer;
    function GetManuallyConstructedObjectProperty: TBase;
  public
    destructor Destroy; override;
  published
    procedure SetUnwriteableIntegerProperty;
    property BooleanProperty: Boolean read FBooleanProperty write FBooleanProperty;
    [Required]
    property DateProperty: TDate read FDateProperty write FDateProperty;
    [Required]
    property DateTimeProperty: TDateTime read FDateTimeProperty write FDateTimeProperty;
    [DefaultValue(5)]
    [Required]
    property IntegerProperty: Integer read FIntegerProperty write FIntegerProperty;
    property ManuallyConstructedObjectProperty: TBase read GetManuallyConstructedObjectProperty;
    [Required]
    property ObjectProperty: TBase2 read FObjectProperty;
    [DefaultValue('Test')]
    [ExcludeFeature([Serializable])]
    [Required]
    property StringProperty: String read FStringProperty write FStringProperty;
    [ExcludeFeature([AutoCreate])]
    property UnconstructedObjectProperty: TgBase read FUnconstructedObjectProperty write FUnconstructedObjectProperty;
    property UnreadableIntegerProperty: Integer write FUnreadableIntegerProperty;
    property UnwriteableIntegerProperty: Integer read FUnwriteableIntegerProperty;
    [Required]
    property String5: TgString5 read FString5 write FString5;
    property Phone: TPhoneString read FPhone write FPhone;
  end;

  TestTBase = class(TTestCase)
  strict private
    Base: TBase;
  public
    procedure PathEndsWithAnObjectProperty;
    procedure PathExtendsBeyondOrdinalProperty;
    procedure PropertyNotReadable;
    procedure PropertyNotWriteable;
    procedure SetPathEndsWithAnObjectProperty;
    procedure SetPathExtendsBeyondOrdinalProperty;
    procedure SetUndeclaredProperty;
    procedure SetUp; override;
    procedure TearDown; override;
    procedure UndeclaredProperty;
  published
    procedure GetValue;
    procedure SetValue;
    procedure Assign;
    procedure DeserializeXML;
    procedure DeserializeJSON;
    procedure SerializeXML;
    procedure SerializeJSON;
    procedure TestCreate;
    procedure ValidateRequired;
  end;

  TestTgString5 = class(TTestCase)
  published
    procedure TestLength;
  end;

  TestTBase2List = class(TTestCase)
  strict private
    FBase2List: TBase2List;
    procedure Add3;
  public
    procedure CurrentOnEmptyList;
    procedure DeleteFromEmptyList;
    procedure GetItemInvalidIndex;
    procedure SetItemInvalidIndex;
    procedure GetValueInvalidIndex;
    procedure NextPastEOL;
    procedure PreviousBeforeBOL;
    procedure SetValueInvalidIndex;
    procedure SetCurrentIndexTooHigh;
    procedure SetCurrentIndexTooLow;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Add;
    procedure Assign;
    procedure BOL;
    procedure EOL;
    procedure CanAdd;
    procedure CanNext;
    procedure CanPrevious;
    procedure Clear;
    procedure Count;
    procedure Current;
    procedure CurrentIndex;
    procedure Delete;
    procedure First;
    procedure GetItem;
    procedure SetItem;
    procedure Last;
    procedure GetValue;
    procedure HasItems;
    procedure ItemClass;
    procedure Next;
    procedure Previous;
    procedure SerializeXML;
    procedure SerializeJSON;
    procedure DeserializeXML;
    procedure DeserializeJSON;
    procedure Filter;
    procedure SetValue;
    procedure Sort;
    procedure TestCreate(BOL: Integer; const Value: string);
  end;

implementation

Uses
  SysUtils,
  Character,
  Math
  ;

procedure TestTBase.GetValue;
begin
  // Given a Pathname, return the property value
  CheckEquals('Test', Base['StringProperty'], 'Non-Object Property');
  CheckEquals('Test', Base['ManuallyConstructedObjectProperty.StringProperty'], 'Object Property');
  // If the property doesn't exist, raise an exception
  CheckException(UndeclaredProperty, TgBase.EgValue);
  // If the path extends beyond an ordinal property, raise an exception
  CheckException(PathExtendsBeyondOrdinalProperty, TgBase.EgValue);
  // If the path ends with an object property, raise an exception
  CheckException(PathEndsWithAnObjectProperty, TgBase.EgValue);
  // If the property is not readable, raise an exception
  CheckException(PropertyNotReadable, TgBase.EgValue);
  // Can we get an Active Value?
  Base.String5 := '123456789';
  CheckEquals('12345', Base['String5'], 'Active Value');
  Base.Phone := '5555555555';
  CheckEquals('(555) 555-5555', Base['Phone'], 'Phone');
  Base.BooleanProperty := True;
  CheckEquals(True, Base['BooleanProperty']);
  CheckEquals('True', Base['BooleanProperty']);
  Base.BooleanProperty := False;
  CheckEquals(False, Base['BooleanProperty']);
  CheckEquals('False', Base['BooleanProperty']);
  Base.DateProperty := StrToDate('1/1/12');
  CheckEquals(StrToDate('1/1/12'), Base['DateProperty'], 'Date as TDate');
  CheckEquals(FloatToStr(StrToDate('1/1/12')), Base['DateProperty'], 'Date as String');
  Base.DateTimeProperty := StrToDateTime('1/1/12 12:34 am');
  CheckEquals(StrToDateTime('1/1/12 12:34 am'), Base['DateTimeProperty'], 'DateTime as TDateTime');
  CheckEquals(FloatToStr(StrToDateTime('1/1/12 12:34 am')), Base['DateTimeProperty'], 'DateTime as String');
end;

procedure TestTBase.PathEndsWithAnObjectProperty;
begin
  Base['ObjectProperty'];
end;

procedure TestTBase.PathExtendsBeyondOrdinalProperty;
begin
  Base['IntegerProperty.ThisShouldNotBeHere'];
end;

procedure TestTBase.PropertyNotReadable;
begin
  Base['UnreadableIntegerProperty'];
end;

procedure TestTBase.PropertyNotWriteable;
begin
  Base['UnwriteableIntegerProperty'] := 5;
end;

procedure TestTBase.SetPathEndsWithAnObjectProperty;
begin
  Base['ObjectProperty'] := 'Test';
end;

procedure TestTBase.SetPathExtendsBeyondOrdinalProperty;
begin
  Base['IntegerProperty.ThisShouldNotBeHere'] := 'Test';
end;

procedure TestTBase.SetUndeclaredProperty;
begin
  Base['ThisPropertyDoesNotExist'] := 'Test';
end;

procedure TestTBase.SetUp;
begin
  Base := TBase.Create;
end;

procedure TestTBase.SetValue;
begin
  // Given a Pathname, set the property value
  Base['StringProperty'] := 'Test2';
  CheckEquals('Test2', Base.StringProperty, 'Non-Object Property');
  Base['ManuallyConstructedObjectProperty.StringProperty'] := 'Test2';
  CheckEquals('Test2', Base.ManuallyConstructedObjectProperty.StringProperty, 'Object Property');
  // If the property doesn't exist, raise an exception
  CheckException(SetUndeclaredProperty, TgBase.EgValue);
  // If the path extends beyond a non-object property, raise an exception
  CheckException(SetPathExtendsBeyondOrdinalProperty, TgBase.EgValue);
  // If the path ends with an object property, raise an exception
  CheckException(SetPathEndsWithAnObjectProperty, TgBase.EgValue);
  // If the property is not writeable, raise an exception
  CheckException(PropertyNotWriteable, TgBase.EgValue);
  // Call a method
  Base['SetUnwriteableIntegerProperty'] := '';
  CheckEquals(10, Base.UnwriteableIntegerProperty);
  Base['ManuallyConstructedObjectProperty.SetUnwriteableIntegerProperty'] := '';
  CheckEquals(10, Base.ManuallyConstructedObjectProperty.UnwriteableIntegerProperty);
  Base['String5'] := '123456789';
  CheckEquals('12345', Base.String5);
  Base['BooleanProperty'] := True;
  CheckEquals(True, Base.BooleanProperty);
  Base['BooleanProperty'] := False;
  CheckEquals(False, Base.BooleanProperty);
  Base['BooleanProperty'] := 'True';
  CheckEquals(True, Base.BooleanProperty);
  Base['BooleanProperty'] := 'False';
  CheckEquals(False, Base.BooleanProperty);
  Base['DateProperty'] := StrToDate('1/1/12');
  CheckEquals(StrToDate('1/1/12'), Base.DateProperty, 'Date as TDate');
  Base['DateProperty'] := '1/1/12';
  CheckEquals(StrToDate('1/1/12'), Base.DateProperty, 'Date as String');
  Base['DateTimeProperty'] := StrToDateTime('1/1/12 12:34 am');
  CheckEquals(StrToDateTime('1/1/12 12:34 am'), Base.DateTimeProperty, 'DateTime as TDateTime');
  Base['DateTimeProperty'] := '1/1/12 12:34 am';
  CheckEquals(StrToDateTime('1/1/12 12:34 am'), Base.DateTimeProperty, 'DateTime as String');
end;

procedure TestTBase.TearDown;
begin
  FreeAndNil(Base);
end;

procedure TestTBase.Assign;
var
  Target: TBase;
begin
  Target := TBase.Create(Base);
  try
    Base.IntegerProperty := 6;
    Base.StringProperty := 'Hello';
    Base.Phone := '5555555555';
    Target.Assign(Base);
    CheckEquals(6, Target.IntegerProperty);
    CheckNull(Target.Inspect(G.PropertyByName(Target, 'ManuallyConstructedObjectProperty')));
    CheckEquals('Test', Target.StringProperty);
    CheckEquals('(555) 555-5555', Target.Phone);
  finally
    Target.Free;
  end;
end;

procedure TestTBase.DeserializeXML;
var
  XMLString: string;
begin
  XMLString :=
    '<xml>'#13#10 + //0
    '  <Base classname="TestgCore.TBase">'#13#10 + //1
    '    <BooleanProperty>True</BooleanProperty>'#13#10 + //2
    '    <DateProperty>1/1/2012</DateProperty>'#13#10 + //3
    '    <DateTimeProperty>1/1/2012 00:34:00</DateTimeProperty>'#13#10 + //4
    '    <IntegerProperty>5</IntegerProperty>'#13#10 + //5
    '    <ManuallyConstructedObjectProperty classname="TestgCore.TBase">'#13#10 + //6
    '      <BooleanProperty>False</BooleanProperty>'#13#10 + //7
    '      <DateProperty>12/30/1899</DateProperty>'#13#10 + //8
    '      <DateTimeProperty>12/30/1899 00:00:00</DateTimeProperty>'#13#10 + //9
    '      <IntegerProperty>6</IntegerProperty>'#13#10 + //10
    '      <ObjectProperty classname="TestgCore.TBase2">'#13#10 + //11
    '        <IntegerProperty>2</IntegerProperty>'#13#10 + //12
    '        <StringProperty>12345</StringProperty>'#13#10 + //13
    '      </ObjectProperty>'#13#10 + //14
    '      <String5>98765</String5>'#13#10 + //15
    '      <Phone>(444) 444-4444</Phone>'#13#10 + //16
    '    </ManuallyConstructedObjectProperty>'#13#10 + //17
    '    <ObjectProperty classname="TestgCore.TBase2">'#13#10 + //18
    '      <IntegerProperty>2</IntegerProperty>'#13#10 + //19
    '      <StringProperty>12345</StringProperty>'#13#10 + //20
    '    </ObjectProperty>'#13#10 + //21
    '    <String5>12345</String5>'#13#10 + //22
    '    <Phone>(555) 555-5555</Phone>'#13#10 + //23
    '  </Base>'#13#10 + //24
    '</xml>'#13#10; //25
  Base.Deserialize(TgSerializerXML, XMLString);
  CheckEquals('12345', Base.String5);
  CheckEquals('(555) 555-5555', Base.Phone);
  CheckEquals(6, Base.ManuallyConstructedObjectProperty.IntegerProperty);
  CheckEquals('98765', Base.ManuallyConstructedObjectProperty.String5);
  CheckEquals('(444) 444-4444', Base.ManuallyConstructedObjectProperty.Phone);
  CheckEquals(True, Base.BooleanProperty);
  CheckEquals(StrToDate('1/1/12'), Base.DateProperty);
  CheckEquals(StrToDateTime('1/1/12 12:34 am'), Base.DateTimeProperty);
end;

procedure TestTBase.DeserializeJSON;
var
  JSONString: string;
begin
  JSONString :=
    '{"ClassName":"TestgCore.TBase","BooleanProperty":"True","DateProperty":"1/'+
    '1/2012","DateTimeProperty":"1/1/2012 00:34:00","IntegerProperty":"5","Manu'+
    'allyConstructedObjectProperty":{"ClassName":"TestgCore.TBase","BooleanProp'+
    'erty":"False","DateProperty":"12/30/1899","DateTimeProperty":"12/30/1899 0'+
    '0:00:00","IntegerProperty":"6","ObjectProperty":{"ClassName":"TestgCore.TB'+
    'ase2","IntegerProperty":"2","StringProperty":"12345"},"String5":"98765","P'+
    'hone":"(444) 444-4444"},"ObjectProperty":{"ClassName":"TestgCore.TBase2","'+
    'IntegerProperty":"2","StringProperty":"12345"},"String5":"12345","Phone":"'+
    '(555) 555-5555"}';
  Base.Deserialize(TgSerializerJSON, JSONString);
  CheckEquals('12345', Base.String5);
  CheckEquals('(555) 555-5555', Base.Phone);
  CheckEquals(6, Base.ManuallyConstructedObjectProperty.IntegerProperty);
  CheckEquals('98765', Base.ManuallyConstructedObjectProperty.String5);
  CheckEquals('(444) 444-4444', Base.ManuallyConstructedObjectProperty.Phone);
  CheckEquals(True, Base.BooleanProperty);
  CheckEquals(StrToDate('1/1/12'), Base.DateProperty);
  CheckEquals(StrToDateTime('1/1/12 12:34 am'), Base.DateTimeProperty);
end;

procedure TestTBase.SerializeXML;
var
  XMLString: string;
begin
  Base.String5 := '123456789';
  Base.Phone := '5555555555';
  Base.ManuallyConstructedObjectProperty.IntegerProperty := 6;
  Base.ManuallyConstructedObjectProperty.String5 := '987654321';
  Base.ManuallyConstructedObjectProperty.Phone := '4444444444';
  Base.BooleanProperty := True;
  Base.DateProperty := StrToDate('1/1/12');
  Base.DateTimeProperty := StrToDateTime('1/1/12 12:34 am');
  XMLString :=
    '<xml>'#13#10 + //0
    '  <Base classname="TestgCore.TBase">'#13#10 + //1
    '    <BooleanProperty>True</BooleanProperty>'#13#10 + //2
    '    <DateProperty>1/1/2012</DateProperty>'#13#10 + //3
    '    <DateTimeProperty>1/1/2012 00:34:00</DateTimeProperty>'#13#10 + //4
    '    <IntegerProperty>5</IntegerProperty>'#13#10 + //5
    '    <ManuallyConstructedObjectProperty classname="TestgCore.TBase">'#13#10 + //6
    '      <BooleanProperty>False</BooleanProperty>'#13#10 + //7
    '      <DateProperty>12/30/1899</DateProperty>'#13#10 + //8
    '      <DateTimeProperty>12/30/1899 00:00:00</DateTimeProperty>'#13#10 + //9
    '      <IntegerProperty>6</IntegerProperty>'#13#10 + //10
    '      <ObjectProperty classname="TestgCore.TBase2">'#13#10 + //11
    '        <IntegerProperty>2</IntegerProperty>'#13#10 + //12
    '        <StringProperty>12345</StringProperty>'#13#10 + //13
    '      </ObjectProperty>'#13#10 + //14
    '      <String5>98765</String5>'#13#10 + //15
    '      <Phone>(444) 444-4444</Phone>'#13#10 + //16
    '    </ManuallyConstructedObjectProperty>'#13#10 + //17
    '    <ObjectProperty classname="TestgCore.TBase2">'#13#10 + //18
    '      <IntegerProperty>2</IntegerProperty>'#13#10 + //19
    '      <StringProperty>12345</StringProperty>'#13#10 + //20
    '    </ObjectProperty>'#13#10 + //21
    '    <String5>12345</String5>'#13#10 + //22
    '    <Phone>(555) 555-5555</Phone>'#13#10 + //23
    '  </Base>'#13#10 + //24
    '</xml>'#13#10; //25
  CheckEquals(XMLString, Base.Serialize(TgSerializerXML));
end;

procedure TestTBase.SerializeJSON;
var
  JSONString: string;
begin
  Base.String5 := '123456789';
  Base.Phone := '5555555555';
  Base.ManuallyConstructedObjectProperty.IntegerProperty := 6;
  Base.ManuallyConstructedObjectProperty.String5 := '987654321';
  Base.ManuallyConstructedObjectProperty.Phone := '4444444444';
  Base.BooleanProperty := True;
  Base.DateProperty := StrToDate('1/1/12');
  Base.DateTimeProperty := StrToDateTime('1/1/12 12:34 am');
  JSONString :=
    '{"ClassName":"TestgCore.TBase","BooleanProperty":"True","DateProperty":"1/'+
    '1/2012","DateTimeProperty":"1/1/2012 00:34:00","IntegerProperty":"5","Manu'+
    'allyConstructedObjectProperty":{"ClassName":"TestgCore.TBase","BooleanProp'+
    'erty":"False","DateProperty":"12/30/1899","DateTimeProperty":"12/30/1899 0'+
    '0:00:00","IntegerProperty":"6","ObjectProperty":{"ClassName":"TestgCore.TB'+
    'ase2","IntegerProperty":"2","StringProperty":"12345"},"String5":"98765","P'+
    'hone":"(444) 444-4444"},"ObjectProperty":{"ClassName":"TestgCore.TBase2","'+
    'IntegerProperty":"2","StringProperty":"12345"},"String5":"12345","Phone":"'+
    '(555) 555-5555"}';
  CheckEquals(JSONString, Base.Serialize(TgSerializerJSON));
end;

procedure TestTBase.TestCreate;
var
  Base1: TBase;
  Base2: TBase2;
begin
  CheckNull(Base.Owner, 'When a constructor is called without a parameter, its owner should be nil.');
  CheckNotNull(Base.ObjectProperty, 'Object properties should be constructed automatically if the Exclude([AutoCreate]) attribute is not set.');
  CheckNull(Base.UnconstructedObjectProperty, 'Object properties with the Exlude([AutoCreate]) attribute should not be nil.');
  Check(Base=Base.ObjectProperty.Owner, 'The owner of an automatically constructed object property shoud be set to the object that created it.');
  CheckEquals(5, Base.IntegerProperty, 'Default integer values should be set for properties with a DefaultValue attribute.');
  CheckEquals('Test', Base.StringProperty, 'Default string values should be set for properties with a DefaultValue attribute.');
  Base2 := TBase2.Create;
  try
    Base1 := TBase.Create(Base2);
    try
      Check(Base1.ObjectProperty = Base2, 'Object properties should take the value of an existing owner object if one exists.');
    finally
      Base1.Free;
    end;
  finally
    Base2.Free;
  end;
end;

procedure TestTBase.UndeclaredProperty;
begin
  Base['ThisPropertyDoesNotExist'];
end;

procedure TestTBase.ValidateRequired;
begin
  Base.DateProperty := Date;
  Base.DateTimeProperty := Now;
  Base.IntegerProperty := 1;
  Base.StringProperty := 'Hello';
  Base.String5 := '12345';
  Base.Phone := '1234567890';
  CheckTrue(Base.IsValid);
  Base.DateProperty := 0;
  CheckFalse(Base.IsValid);
  Check(Base.ValidationErrors['DateProperty'] > '');
  Base.DateProperty := Date;
  Base.DateTimeProperty := 0;
  CheckFalse(Base.IsValid);
  Check(Base.ValidationErrors['DateTimeProperty'] > '');
end;

destructor TBase.Destroy;
begin
  FreeAndNil(FManuallyConstructedObjectProperty);
  inherited Destroy;
end;

function TBase.GetManuallyConstructedObjectProperty: TBase;
begin
  if Not IsInspecting And Not Assigned(FManuallyConstructedObjectProperty) then
    FManuallyConstructedObjectProperty := TBase.Create(Self);
  Result := FManuallyConstructedObjectProperty;
end;

procedure TBase.SetUnwriteableIntegerProperty;
begin
  FUnwriteableIntegerProperty := 10;
end;

function TgString5.GetValue: String;
begin
  Result := FValue;
end;

procedure TgString5.SetValue(const AValue: String);
begin
  FValue := Copy(AValue, 1, 5);
end;

class operator TgString5.implicit(AValue: Variant): TgString5;
begin
  Result.Value := AValue;
end;

class operator TgString5.Implicit(AValue: TgString5): Variant;
begin
  Result := AValue.Value;
end;

procedure TestTgString5.TestLength;
var
  String5: TgString5;
begin
  String5 := '123456789';
  CheckEquals('12345', String5);
end;

function TPhoneString.FormatPhone(AValue : String): String;
Var
  CurrentCharacter: Char;
Begin
  Result := '';
  for CurrentCharacter in AValue do
  Begin
    if IsNumber(CurrentCharacter) then
      Result := Result + CurrentCharacter;
  End;
  Case Length(Result) Of
    7 :
    Begin
      Insert('(   ) ', Result, 1);
      Insert('-', Result, 10);
    End;
    10 :
    Begin
      Insert('(', Result, 1);
      Insert(') ', Result, 5);
      Insert('-', Result, 10);
    End;
    Else
      Result := AValue;
  End;
End;

function TPhoneString.GetValue: String;
begin
  Result := FValue;
end;

procedure TPhoneString.SetValue(const AValue: String);
begin
  FValue := FormatPhone(AValue);
end;

class operator TPhoneString.Implicit(AValue: TPhoneString): Variant;
begin
  Result := AValue.Value;
end;

class operator TPhoneString.Implicit(AValue: Variant): TPhoneString;
begin
  Result.Value := AValue;
end;

procedure TestTBase2List.Add;
begin
  Add3;
  CheckEquals(3, FBase2List.Count, 'There should be 3 items in the list.');
  CheckEquals(3, FBase2List.Current.IntegerProperty, 'The last item added should be the current one.');
  CheckEquals(2, FBase2List.CurrentIndex, 'The CurrentIndex value should be one less than the count.');
  CheckEquals(TBase2, FBase2List.Current.ClassType, 'Constructs the new list item from ItemClass, which in this case, is the generic class.');
  FBase2List.ItemClass := TBase3;
  FBase2List.Add;
  CheckEquals(TBase3, FBase2List.Current.ClassType, 'Constructs the new list item from the new ItemClass.');
end;

procedure TestTBase2List.Add3;
var
  Counter: Integer;
begin
  for Counter := 1 to 3 do
  Begin
    FBase2List.Add;
    FBase2List.Current.IntegerProperty := Counter;
  End;
end;

procedure TestTBase2List.Assign;
var
  NewBase2List: TBase2List;
begin
  Add3;
  NewBase2List := TBase2List.Create;
  try
    NewBase2List.Assign(FBase2List);
    CheckEquals(3, NewBase2List.Count, 'Should have copied 3 items.');
    CheckEquals(3, NewBase2List[2].IntegerProperty, 'Make sure the value got copied.');
  finally
    NewBase2List.Free;
  end;
end;

procedure TestTBase2List.BOL;
begin
  CheckTrue(FBase2List.BOL, 'When there are no items, BOL should be true.');
  FBase2List.Add;
  CheckFalse(FBase2List.BOL, 'When there is one item and it''s the current one, BOL should be false.');
  FBase2List.Previous;
  CheckTrue(FBase2List.BOL, 'If you try to move before the first item, BOL should be true');
  FBase2List.Last;
  CheckFalse(FBase2List.BOL, 'This should make the only item current and set EOL, but not BOL.');
  FBase2List.First;
  CheckTrue(FBase2List.BOL, 'Calling First shoule make BOL true.');
end;

procedure TestTBase2List.EOL;
begin
  CheckTrue(FBase2List.EOL, 'When there are no items, EOL should be true.');
  FBase2List.Add;
  CheckFalse(FBase2List.EOL, 'When there is one item and it''s the current one, EOL should be false.');
  FBase2List.Next;
  CheckTrue(FBase2List.EOL, 'If you try to move after the only item, EOL should be true');
  FBase2List.First;
  CheckFalse(FBase2List.EOL, 'This should make the only item current, but not set EOL.');
  FBase2List.Last;
  CheckTrue(FBase2List.EOL, 'Calling Last shoule make EOL true.');
end;

procedure TestTBase2List.CanAdd;
begin
  CheckTrue(FBase2List.CanAdd);
end;

procedure TestTBase2List.CanNext;
begin
  CheckFalse(FBase2List.CanNext, 'Always false for an empty list.');
  FBase2List.Add;
  CheckFalse(FBase2List.CanNext, 'Always false for the last item in the list.');
  FBase2List.Add;
  FBase2List.Previous;
  CheckTrue(FBase2List.CanNext, 'Always true if list not empty and not on the last item.');
end;

procedure TestTBase2List.CanPrevious;
begin
  CheckFalse(FBase2List.CanPrevious, 'Always false for an empty list.');
  FBase2List.Add;
  CheckFalse(FBase2List.CanPrevious, 'Always false for the first item in the list.');
  FBase2List.Add;
  CheckTrue(FBase2List.CanPrevious, 'Always true if list not empty and not on the first item.');
end;

procedure TestTBase2List.Clear;
begin
  Add3;
  FBase2List.Clear;
  CheckEquals(0, FBase2List.Count);
end;

procedure TestTBase2List.Count;
begin
  CheckEquals(0, FBase2List.Count, 'When a list is created it has no items');
  Add3;
  FBase2List.Delete;
  CheckEquals(2, FBase2List.Count, 'The count equals the number of items added minus the number deleted.');
end;

procedure TestTBase2List.Current;
begin
  CheckException(CurrentOnEmptyList,TgList.EgList, 'Calling Current on an empty list should cause an exception.');
  Add3;
  FBase2List.CurrentIndex := 1;
  CheckEquals(2, FBase2List.Current.IntegerProperty, 'If there are items in the list, Current returns the item at CurrentIndex (zero based).');
end;

procedure TestTBase2List.CurrentIndex;
begin
  CheckEquals(-1, FBase2List.CurrentIndex, 'CurrentIndex should be -1 on an empty list.');
  Add3;
  while Not FBase2List.BOL do
  Begin
    Check(InRange(FBase2List.CurrentIndex, 0, FBase2List.Count - 1), Format('%d is not in range 0..%d', [FBase2List.CurrentIndex, FBase2List.Count - 1]));
    FBase2List.Previous;
  End;
  FBase2List.Last;
  FBase2List.Delete;
  CheckEquals(1, FBase2List.CurrentIndex, 'When Current is Last, and it gets deleted, CurrentIndex matched the new Last');
  FBase2List.CurrentIndex := 0;
  CheckEquals(0, FBase2List.CurrentIndex, 'Setting CurrentIndex to a valid value should allow you to get that same value.');
  CheckException(SetCurrentIndexTooLow, TgList.EgList, 'CurrentIndex must be greater than or equal to 0.');
  CheckException(SetCurrentIndexTooHigh, TgList.EgList, 'CurrentIndex must be less than or equal to Count - 1.');
end;

procedure TestTBase2List.CurrentOnEmptyList;
begin
  FBase2List.Clear;
  FBase2List.Current;
end;

procedure TestTBase2List.Delete;
begin
  CheckException(DeleteFromEmptyList, TgList.EgList, 'The Delete method may not be called from an empty list.');
  Add3;
  FBase2List.CurrentIndex := 1;
  FBase2List.Delete;
  CheckEquals(2, FBase2List.Count, 'Deleting one of the 3 list items should yield a count of 2.');
  CheckEquals(3, FBase2List.Current.IntegerProperty, 'The 3rd item should have taken the place of the 2nd');
end;

procedure TestTBase2List.DeleteFromEmptyList;
begin
  FBase2List.Clear;
  FBase2List.Delete;
end;

procedure TestTBase2List.First;
begin
  Add3;
  FBase2List.First;
  CheckTrue(FBase2List.BOL, 'First should set BOL');
  CheckEquals(0, FBase2List.CurrentIndex, 'CurrentIndex should be at 0.');
end;

procedure TestTBase2List.GetItem;
begin
  Add3;
  CheckEquals(2, FBase2List.Items[1].IntegerProperty, 'Get the 2nd item in the array');
  CheckException(GetItemInvalidIndex, TgList.EgList, 'Invalid Index');
end;

procedure TestTBase2List.SetItem;
begin
  Add3;
  FBase2List.Items[1].IntegerProperty := 22;
  CheckEquals(22, FBase2List.Items[1].IntegerProperty, 'Get the 2nd item in the array');
  CheckException(SetItemInvalidIndex, TgList.EgList, 'Invalid Index');
end;

procedure TestTBase2List.GetItemInvalidIndex;
begin
  FBase2List.Items[23].IntegerProperty := FBase2List.Items[23].IntegerProperty + 1;
end;

procedure TestTBase2List.SetItemInvalidIndex;
begin
  FBase2List.Items[23].IntegerProperty := 22;
end;

procedure TestTBase2List.Last;
begin
  Add3;
  FBase2List.First;
  FBase2List.Last;
  CheckTrue(FBase2List.EOL, 'Last should set EOL');
  CheckEquals(2, FBase2List.CurrentIndex, 'CurrentIndex should be at 2.');
end;

procedure TestTBase2List.GetValue;
begin
  Add3;
  CheckEquals(3, FBase2List.Values['Current.IntegerProperty'], 'Testing the inherited GetValue');
  CheckEquals(2, FBase2List.Values['[1].IntegerProperty'], 'Testing the overridden GetValues that looks for an index value');
  CheckException(GetValueInvalidIndex, TgBase.EgValue, 'Invalid Index');
end;

procedure TestTBase2List.SetValue;
begin
  FBase2List.Add;
  FBase2List.Values['Current.IntegerProperty'] := 1;
  CheckEquals(1, FBase2List.Current.IntegerProperty, 'Testing the inherited SetValue');
  FBase2List.Values['[0].IntegerProperty'] := 2;
  CheckEquals(2, FBase2List[0].IntegerProperty, 'Testing the overriden SetValue looking for an index value.');
  CheckException(SetValueInvalidIndex, TgBase.EgValue, 'Invalid Index');
end;

procedure TestTBase2List.GetValueInvalidIndex;
begin
  FBase2List.Values['[xyz].IntegerProperty'];
end;

procedure TestTBase2List.HasItems;
begin
  CheckFalse(FBase2List.HasItems, 'Should return False on an empty list.');
  FBase2List.Add;
  CheckTrue(FBase2List.HasItems, 'Should return True on a non-empty list.');
end;

procedure TestTBase2List.ItemClass;
begin
  Check(FBase2List.ItemClass = TBase2, 'The default ItemClass should be the generic type.');
  FBase2List.ItemClass := TBase3;
  CheckEquals(TBase3, FBase2List.ItemClass, 'Should return the ItemClass that was set.');
  FBase2List.ItemClass := Nil;
  Check(FBase2List.ItemClass = TBase2, 'The default ItemClass should be the generic type.');
end;

procedure TestTBase2List.Next;
begin
  CheckException(NextPastEOL, TgList.EgList, 'Exception calling on Empty List');
  Add3;
  FBase2List.Last;
  FBase2List.Previous;
  FBase2List.Next;
  CheckEquals(2, FBase2List.CurrentIndex, 'Should be CurrentIndex2');
  FBase2List.Next;
  CheckTrue(FBase2List.EOL);
  CheckException(NextPastEOL, TgList.EgList, 'Exception calling on EOL.');
end;

procedure TestTBase2List.Previous;
begin
  CheckException(PreviousBeforeBOL, TgList.EgList, 'Exception calling on Empty List');
  Add3;
  FBase2List.First;
  FBase2List.Next;
  FBase2List.Previous;
  CheckEquals(0, FBase2List.CurrentIndex, 'CurrentIndex should be 0');
  FBase2List.Previous;
  CheckTrue(FBase2List.BOL);
  CheckException(PreviousBeforeBOL, TgList.EgList, 'Exception calling on EOL.');
end;

procedure TestTBase2List.NextPastEOL;
begin
  FBase2List.Next;
end;

procedure TestTBase2List.PreviousBeforeBOL;
begin
  FBase2List.Previous;
end;

procedure TestTBase2List.SerializeXML;
var
  XMLString: string;
begin
  Add3;
  XMLString :=
    '<xml>'#13#10 + //0
    '  <Base2List classname="TestgCore.TBase2List">'#13#10 + //1
    '    <Base2 classname="TestgCore.TBase2">'#13#10 + //2
    '      <IntegerProperty>1</IntegerProperty>'#13#10 + //3
    '      <StringProperty>12345</StringProperty>'#13#10 + //4
    '    </Base2>'#13#10 + //5
    '    <Base2 classname="TestgCore.TBase2">'#13#10 + //6
    '      <IntegerProperty>2</IntegerProperty>'#13#10 + //7
    '      <StringProperty>12345</StringProperty>'#13#10 + //8
    '    </Base2>'#13#10 + //9
    '    <Base2 classname="TestgCore.TBase2">'#13#10 + //10
    '      <IntegerProperty>3</IntegerProperty>'#13#10 + //11
    '      <StringProperty>12345</StringProperty>'#13#10 + //12
    '    </Base2>'#13#10 + //13
    '  </Base2List>'#13#10 + //14
    '</xml>'#13#10; //15
  CheckEquals(XMLString, FBase2List.Serialize(TgSerializerXML));
end;

procedure TestTBase2List.SerializeJSON;
var
  JSONString: string;
begin
  Add3;
  JSONString :=
  '{"ClassName":"TestgCore.TBase2List","List":[{"ClassName":"TestgCore.TBase2'+
  '","IntegerProperty":"1","StringProperty":"12345"},{"ClassName":"TestgCore.'+
  'TBase2","IntegerProperty":"2","StringProperty":"12345"},{"ClassName":"Test'+
  'gCore.TBase2","IntegerProperty":"3","StringProperty":"12345"}]}';
  CheckEquals(JSONString, FBase2List.Serialize(TgSerializerJSON));
end;

procedure TestTBase2List.DeserializeXML;
var
  XMLString: string;
begin
  XMLString :=
    '<xml>'#13#10 + //0
    '  <Base2List classname="TestgCore.TBase2List">'#13#10 + //1
    '    <Base2 classname="TestgCore.TBase2">'#13#10 + //2
    '      <IntegerProperty>1</IntegerProperty>'#13#10 + //3
    '      <StringProperty>12345</StringProperty>'#13#10 + //4
    '    </Base2>'#13#10 + //5
    '    <Base2 classname="TestgCore.TBase2">'#13#10 + //6
    '      <IntegerProperty>2</IntegerProperty>'#13#10 + //7
    '      <StringProperty>12345</StringProperty>'#13#10 + //8
    '    </Base2>'#13#10 + //9
    '    <Base2 classname="TestgCore.TBase2">'#13#10 + //10
    '      <IntegerProperty>3</IntegerProperty>'#13#10 + //11
    '      <StringProperty>12345</StringProperty>'#13#10 + //12
    '    </Base2>'#13#10 + //13
    '  </Base2List>'#13#10 + //14
    '</xml>'#13#10; //15
  FBase2List.Deserialize(TgSerializerXML, XMLString);
  CheckEquals(3, FBase2List.Items[2].IntegerProperty);
end;

procedure TestTBase2List.DeserializeJSON;
var
  JSONString: string;
begin
  JSONString :=
  '{"ClassName":"TestgCore.TBase2List","List":[{"ClassName":"TestgCore.TBase2'+
  '","IntegerProperty":"1","StringProperty":"12345"},{"ClassName":"TestgCore.'+
  'TBase2","IntegerProperty":"2","StringProperty":"12345"},{"ClassName":"Test'+
  'gCore.TBase2","IntegerProperty":"3","StringProperty":"12345"}]}';
  FBase2List.Deserialize(TgSerializerJSON, JSONString);
  CheckEquals(3, FBase2List.Items[2].IntegerProperty);
end;

procedure TestTBase2List.Filter;
begin
  Add3;
  FBase2List.Where := 'IntegerProperty > 1';
  FBase2List.Filter;
  CheckEquals(2, FBase2List.Count);
  CheckEquals(2, FBase2List.Current.IntegerProperty);
end;

procedure TestTBase2List.SetValueInvalidIndex;
begin
  FBase2List.Values['[xyz].IntegerProperty'] := 2;
end;

procedure TestTBase2List.SetCurrentIndexTooHigh;
begin
  FBase2List.CurrentIndex := FBase2List.Count;
end;

procedure TestTBase2List.SetCurrentIndexTooLow;
begin
  FBase2List.CurrentIndex := -1;
end;

procedure TestTBase2List.SetUp;
begin
  FBase2List := TBase2List.Create;
end;

procedure TestTBase2List.Sort;
begin
  Add3;
  FBase2List.OrderBy := 'StringProperty, IntegerProperty DESC';
  FBase2List.Sort;
  FBase2List.First;
  CheckEquals(3, FBase2List.Current.IntegerProperty);
  FBase2List.Next;
  CheckEquals(2, FBase2List.Current.IntegerProperty);
  FBase2List.Next;
  CheckEquals(1, FBase2List.Current.IntegerProperty);
end;

procedure TestTBase2List.TearDown;
begin
  FBase2List.Free;
  FBase2List := nil;
end;

procedure TestTBase2List.TestCreate(BOL: Integer; const Value: string);
begin
  CheckEquals(0, FBase2List.Count, 'A list has no items after it gets created.');
  CheckEquals(-1, FBase2List.CurrentIndex, 'The CurrentIndex is set to -1 if there are no list items.');
end;

procedure ValidatePhone.Execute(AObject: TgObject; ARTTIProperty: TRttiProperty);
var
  ValueLength: Integer;
begin
  ValueLength := Length(AObject[ARTTIProperty.Name]);
  if InRange(ValueLength, 1, 6) then
    AObject.ValidationErrors[ARTTIProperty.Name] := 'A phone number must contain at least seven digits.';
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTBase.Suite);
  RegisterTest(TestTgString5.Suite);
  RegisterTest(TestTBase2List.Suite);
end.









