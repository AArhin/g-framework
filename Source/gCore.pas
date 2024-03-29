unit gCore;

interface

Uses

  Generics.Collections,
  Generics.Defaults,
  Winapi.ShlObj,
  Winapi.SHFolder,
  System.TypInfo,
  System.Types,
  System.RTTI,
  System.SysUtils,
  Data.DBXJSON,
  Data.DBXPlatform,
  Xml.XMLDoc,
  Xml.XMLIntf,
  Contnrs,
  RegularExpressions,
  System.Classes,
  gExpressionConstants,
  gExpressionLiterals,
  gExpressionOperators,
  gExpressionFunctions,
  Data.SQLExpr,
  Data.DB,
  SyncObjs
;

const
  CRLF = #13#10;
  TAB = #9;
  DaysOfWeek: array[1..7] of string = (
    'Sun', 'Mon', 'Tue', 'Wed',
    'Thu', 'Fri', 'Sat');
  Months: array[1..12] of string = (
    'Jan', 'Feb', 'Mar', 'Apr',
    'May', 'Jun', 'Jul', 'Aug',
    'Sep', 'Oct', 'Nov', 'Dec');

    type

  TSystemCustomAttribute = System.TCustomAttribute; // Gets around Class complete not supporting the . in some generics
  TCustomAttributeClass = class of TCustomAttribute;
  TgBaseClass = class of TgBase;
  TgPersistenceManagerClass = class of TgPersistenceManager;
  {$M+}
  TgBase = class;
  {$M-}

  TgTransactionIsolationLevel = ( ilReadCommitted, ilSnapshot, ilSerializable );

  TgList = class;
  TgObject = class;


  TgIdentityObjectClass = class of TgIdentityObject;
  TgIdentityObject = class;
  TgPersistenceManager = class;

  TgIdentityList = class;
  TgDictionary = class;


  TgModel = class;
  TgConnectionDescriptor = class;
  TgServer = class;
  TgConnection = class;
  TgPropertyAttribute = class(TCustomAttribute)
  strict private
    FRTTIProperty: TRTTIProperty;
  public
    property RTTIProperty: TRTTIProperty read FRTTIProperty write FRTTIProperty;
  end;

  Caption = class(TgPropertyAttribute)
  public
    Value: String;
    constructor Create(const AValue: String);
  end;

  Columns = class(TgPropertyAttribute)
  public
    Names: TStringDynArray;
    constructor Create(const PropertyNames: String);
  end;

  DisplayOnly = class(TgPropertyAttribute)
  end;

  Help = class(TgPropertyAttribute)
  public
    Value: String;
    constructor Create(const AValue: String);
  end;
  FormatFloat = class(TgPropertyAttribute)
  public
    Value: String;
    constructor Create(const AValue: String);
  end;
  DefaultValue = class(TgPropertyAttribute)
  Strict Private
    FValue : Variant;
  Public
    Constructor Create(Const AValue : String); Overload;
    Constructor Create(AValue : Integer); Overload;
    Constructor Create(AValue : Double); Overload;
    Constructor Create(AValue : TDateTime); Overload;
    Constructor Create(AValue : Boolean); Overload;
    procedure Execute(ABase: TgBase);
    Property Value : Variant Read FValue;
  End;

  ///	<summary>
  ///	  Used on published properties decend from a class <see cref="TgObject" />
  ///	  .  <see cref="TgObject" /> is the base class which will validate
  ///	  published properties
  ///	</summary>
  ///	<remarks>
  ///	  See <see cref="TgObject.IsValid" />
  ///	</remarks>
  Validation = class(TCustomAttribute)
  public
    procedure Execute(AObject: TgObject; ARTTIProperty: TRTTIProperty); virtual; abstract;
  end;

  ValidationRegEx = class(Validation)
  public
    RegExSearch: String;
    RegExReplacement: String;
    procedure Create(const ARegExSearch: String; const ARegExReplacement: String = '');
    procedure Execute(AObject: TgObject; ARTTIProperty: TRTTIProperty); override;
  end;

  ///	<summary>
  ///	  Inheriting from <see cref="Validation" />, Using this attribute with
  ///	  property will require the property to be populated durring Validation
  ///	</summary>
  ///	<remarks>
  ///	  See <see cref="TgObject.IsValid" />
  ///	</remarks>
  Required = class(Validation)
  strict protected
    FEnabled: Boolean;
  public
    constructor Create; virtual;
    procedure Execute(AObject: TgObject; ARTTIProperty: TRTTIProperty); override;
    property Enabled: Boolean read FEnabled;
  end;

  ///	<summary>
  ///	  Inheriting from <see cref="Required" /> this attribute when assigned to a property, will instruct <see cref="G" /> override any Required attribute from its ancestor
  ///	  class rendering the property not required during the validation process
  ///	</summary>
  ///	<remarks>
  ///	  See <see cref="TgObject.IsValid" />
  ///	</remarks>
  NotRequired = class(Required)
  public
    constructor Create; override;
  end;

  ///	<summary>
  ///	  Specifies that the associated published property should be used in a
  ///	  Serialization process
  ///	</summary>
  ///	<remarks>
  ///	  <see cref="TgSerializer">
  ///	</remarks>
  Serializable = class(TCustomAttribute)
  end;

  ///	<summary>
  ///	  Specifies that the associated published property should be ignored in a
  ///	  Serialization process
  ///	</summary>
  ///	<remarks>
  ///	  <see cref="TgSerializer">
  ///	</remarks>
  NotSerializable = class(TCustomAttribute)
  end;

  NotPersistable = class(TCustomAttribute)
  end;

  ///	<summary>
  ///	  Inheriting from <see cref="Required" /> this attribute when assigned to a property, will instruct <see cref="G" /> override any Required attribute from its ancestor
  ///	  class rendering the property not required during the validation process
  ///	</summary>
  ///	<remarks>
  ///	  See <see cref="TgBase.Assign()" />
  ///	</remarks>
  NotAssignable = class(TCustomAttribute)
  end;


  ///	<summary>
  ///	  this Attribute will force the associated class reference property that decends from <see cref="TgBase" /> to
  ///	  be created and assigned to that property when the class is constructed
  ///	</summary>
  ///	<remarks>
  ///	  <see cref="TgObject.AutoCreate" />
  ///	</remarks>
  AutoCreate = class(TCustomAttribute)
  end;

  ///	<summary>
  ///	  this Attribute will stop the Auto Creation for the associated class reference property that decends from <see cref="TgBase" /> to
  ///	  be created and assigned to that property when the class is constructed
  ///	</summary>
  ///	<remarks>
  ///	  <see cref="TgObject.AutoCreate" />
  ///	</remarks>
  NotAutoCreate = class(TCustomAttribute)
  end;

  ///	<summary>
  ///	  This attribute is used to identify properties should be rendered in the
  ///	  User Interface
  ///	</summary>
  Visible = class(TCustomAttribute)
  end;

  ///	<summary>
  ///	  This attribute flags a property to be hidden when the user interface is
  ///	  rendered
  ///	</summary>
  NotVisible = class(TCustomAttribute)
  end;


{ TODO -oJim -cDefinations : Needs more work }
  ///	<summary>
  ///	  used on a class property when you want the serializer to persist the
  ///	  properties contained within the class.
  ///	</summary>
  Composite = class(TCustomAttribute)
  end;

{ TODO -oJim -cDefinations : Need Defination }
  NotComposite = class(TCustomAttribute)
  end;


  ///	<summary>
  ///	  Marking a class property with Singleton will cause it to be automaticly
  ///	  loaded when referenced.    It basicly means theres only one of them so
  ///	  go ahead and load it.
  ///	</summary>
  ///	<remarks>
  ///	  the LoadSingletons on the creation of the object it will load the ID=1
  ///	  into that structure.
  ///	</remarks>
  Singleton = class(TgPropertyAttribute)
  end;

  ///	<summary>
  ///	  <para>
  ///	    Used to attach a HTML control to a Delphi Type.  Using the format of
  ///	    a Delphi format() function here is the breakdown of parameters
  ///	  </para>
  ///	  <para>
  ///	    %0:s   Field Label - Readable Name<br />%1:s   Id - FieldName<br />%2:
  ///	    s   Value - CurrentValue<br />%3:s   Additional Attributes
  ///	  </para>
  ///	</summary>
  ///	<remarks>
  ///	  &lt;textarea class="HTMLEditor" id="%1:s" name="%1:s"
  ///	  %3&gt;%2:s&lt;/textarea&gt;'
  ///	</remarks>
  HTMLControlAttribute = class(TCustomAttribute)
    HTML: String;
    constructor Create(const AHTML: String);
  end;

  HTMLAttribute= class(TCustomAttribute)
  public
    Name: String;
    Value: Variant;
    constructor Create(const AName: String; const AValue: String);
    function AsText: String;
  end;

  THTMLAttributes = TArray<HTMLAttribute>;

  HTMLText = class(HTMLAttribute)
  public
    constructor Create;
  end;

  LocalFileName = class(HTMLAttribute)
  public
    constructor Create;
  end;
  WebAddress = class(HTMLAttribute)
  public
    constructor Create;
  end;

  MaxTextLength = class(TgPropertyAttribute)
  private
    Fmaxlength: Integer;
    Fsize: Integer;
  public
    constructor Create(AMaxLength: Integer; ASize: Integer = -1);
    property maxlength: Integer read Fmaxlength;
    property size: Integer read Fsize;

  end;

  [HTMLText]
  TgHTMLString = Type String;

  [LocalFileName]
  TgFileName = Type String;

  TgImage = type string;

  TgEmailAddress = type string;

  [WebAddress]
  TgWebAddress = type string;

  TgSerializerClass = class of TgSerializer;


  ///	<summary>
  ///	  This is the base class all serializers will decend from.  It is used to
  ///	  serialize the published properties of a <see cref="TgBase" />
  ///	</summary>
  TgSerializer = Class(TObject)
  public

    type
      E = class(Exception)
      end;

    { TODO -oJim -cDefinations : I need to better understand the helper relationship to the Serialization class }
      THelperClass = class of THelper;
    { TODO -oJim -cDefinations : What is the difference between a helper and the regular serialization strucutre }
      THelper = class(TObject)
      type
        TComparer = class(TComparer<TPair<TgBaseClass, THelperClass>>)
          function Compare(const Left, Right: TPair<TgBaseClass, THelperClass>): Integer; override;
        end;

      public
        class function BaseClass: TgBaseClass; virtual; abstract;
        class function SerializerClass: TgSerializerClass; virtual; abstract;
        class procedure Serialize(AObject: TgBase; ASerializer: TgSerializer; ARTTIProperty: TRTTIProperty = Nil); virtual; abstract;
        class procedure Deserialize(AObject: TgBase; ASerializer: TgSerializer; ARTTIProperty: TRTTIProperty = Nil); virtual; abstract;
        class procedure DeserializeUnpublishedProperty(AObject: TgBase; ASerializer: TgSerializer; const PropertyName: String); virtual; abstract;
      end;
  Public
    constructor Create; virtual;
    procedure AddObjectProperty(ARTTIProperty: TRTTIProperty; AObject: TgBase); virtual; abstract;
    procedure AddValueProperty(const AName: String; AValue: Variant); virtual; abstract;
    function CreateAndDeserialize(const AString: String; AOwner: TgBase = Nil): TgBase;
    procedure Deserialize(AObject: TgBase; const AString: String); virtual; abstract;
    function ExtractClassName(const AString: string): String; virtual; abstract;
    function Serialize(AObject: TgBase; ADefaultClass: TgBaseClass = nil): String; virtual; abstract;
  End;


  TgSerializationHelperClass = TgSerializer.THelperClass;



  /// <summary>TgBase is the base ancestor of all application specific classes you
  /// create in <see cref="G" />
  /// </summary>
  TgBase = class(TObject)
  private
    function GetCaptions(const AName: String): String; overload;
    function GetHelps(const AName: String): String; overload;
  protected
    type
      TState =
        (
          // TgBase
          osAutoCreating, osInspecting,
          // TgIdentityObject
          osCreatingOriginalValues, osOriginalValues, osLoaded, osLoading, osSaving, osDeleting,
          // TgList
          osOrdered, osFiltered, osSorted, osActivating, osActive
        );
      TStates = Set of TState;

    function GetObjectChildPathName(AChild: TgBase = nil): String; virtual;
    function DoUseRestPath(const Path: String; var TemplateName: String; out gBase: TgBase; const Delim: char = '/'): Boolean; virtual;
  public
    type
      /// <summary>
      /// Raised when a <see cref="TgBase" /> is assigned to another <see cref="TgBase"
      /// /> and there is a failure in that process
      /// </summary>
      EgAssign = class(Exception)
      end;
      /// <summary>
      ///   Used to return a path error for <see cref="TgBase.DoGetValues" /> and <see
      ///   cref="TgBase.DoSetValues" /> used by the <see cref="TgBase.Values" />
      /// </summary>
      EgValue = class(Exception)
      end;

      TPathValue = record
        Path: String;
        Value: Variant;
        RTTIProperty: TRttiProperty;
        class operator Implicit(const Value: TPathValue): Variant;
        function IsClass(AClass: TClass): Boolean; overload;
        function IsClass(const AClasses: array of TClass): Integer; overload;
        function Empty: Boolean;
        function IsDefault(ARttiInstanceProperty: TRttiInstanceProperty): Boolean;
        function Text: String;
      end;

  strict private
    function GetModel: TgModel;
  strict protected
    type
      TEnumerator = record
      private
        FCurrentIndex: Integer;
        FCount: Integer;
        FItem: TgBase;
        function GetCurrent: TPathValue; {$IFDEF DEBUG}inline;{$ENDIF}
      public
        procedure Init(AItem: TgBase); inline;
        function MoveNext: Boolean; inline;
        property Current: TPathValue read GetCurrent;
      end;

    var
    FOwner: TgBase;
    FOwnerProperty: TRTTIProperty;
    FStates: TStates;

    /// <summary>TgBase.AutoCreate gets called by the Create constructor to instantiate
    /// object properties. You may override this method in a descendant class to alter
    /// its behavior.
    /// </summary>
    procedure AutoCreate; virtual;
    function GetPathCount: Integer; virtual;
    function GetPaths(AIndex: Integer): String; virtual;
    function GetPathValues(AIndex: Integer): TPathValue;
    function DoGetObjects(const APath: String; out AValue: TgBase): Boolean; virtual;
    function DoSetValues(Const APath : String; AValue : Variant): Boolean; virtual;
    function GetValues(Const APath : String): Variant; virtual;
    function GetObjects(Const APath : String): TgBase; virtual;
    function GetProperties(Const APath : String): TRTTIProperty; virtual;
    function GetStates(Index: TgBase.TState): Boolean;
    /// <summary>TgBase.OwnerByClass walks up the Owner path looking for an owner whose
    /// class type matches the AClass parameter. This method gets used by the
    /// AutoCreate method to determine if an object property should get created, or
    /// reference an existing object up the owner tree.
    /// </summary>
    /// <returns> TgBase
    /// </returns>
    /// <param name="AClass"> (TgBaseClass) </param>
    function OwnerByClass(AClass: TgBaseClass): TgBase; virtual;
    procedure SetStates(const AIndex: TgBase.TState; const AValue: Boolean);
        virtual;
    procedure SetValues(Const APath : String; AValue : Variant); virtual;
  public
    /// <summary>TgBase.Create instantiates a new G object, sets its owner and
    /// automatically
    /// instantiates any object properties descending from TgBase that don't have the
    /// ExcludeFeatures
    /// attribute with an AutoCreate</summary>
    /// <param name="AOwner"> (TgBase) </param>
    constructor Create(AOwner: TgBase = Nil); virtual;
    class function AddAttributes(ARTTIProperty: TRttiProperty): TArray<TCustomAttribute>; virtual;
    procedure Assign(ASource : TgBase); virtual;
    procedure Deserialize(ASerializerClass: TgSerializerClass; const AString: String);
    function GetEnumerator: TEnumerator; inline;
    class function ApplicationPath: String;
    class function DataPath: String;
    class function FriendlyName: String; virtual;
    function GetFriendlyClassName: String; virtual;
    function Inspect(ARTTIProperty: TRttiProperty): TObject; overload;
    function OwnerProperty: TRTTIProperty;
    function GetCaptions(const RTTIProperty: TRTTIProperty): String; overload;
    function GetHelps(const RTTIProperty: TRTTIProperty): String; overload;
    /// <summary>TgBase.Owns determines if the object passed into  the ABase parameter
    /// has Self as its owner.
    /// </summary>
    /// <returns> Boolean
    /// </returns>
    /// <param name="ABase"> (TgBase) </param>
    function Owns(ABase : TgBase): Boolean;

    ///	<summary>
    ///	  Ths method was added to referer to the self as a pointer when passing
    ///	  a this structure as a generic into a parameter for a function or
    ///	  procedure that requires a pointer type
    ///	</summary>
    ///	<remarks>
    ///	  This is really used to overcome a compiler error in XE2
    ///	</remarks>
    function AsPointer: Pointer; inline;
    class function Captionize(const AValue: String): String; virtual;
    function DoGetInValues(const APath: String; const Name: String): Boolean; virtual;
    class function DoGetMembers(const APath: String; out AValue: TRttiMember): boolean;
        virtual;
    class function DoGetMethods(const APath: String; out AValue: TRttiMethod): Boolean; virtual;
    class function DoGetProperties(const APath: String; out ARTTIProperty: TRTTIProperty; AgBase: TgBase = nil): Boolean; virtual;
    function DoGetValues(Const APath : String; Out AValue : Variant): Boolean; overload; virtual;
    function DoGetValues(ARttiProperty: TRttiProperty; out AValue: Variant; const
        ATail: String = ''): Boolean; overload; virtual;
    class function GetAttribute<T>(ARttiNamedObject: TRttiNamedObject): T; overload;
    class function GetAttribute<T>(ARttiNamedObject: TRttiNamedObject; out
        Attribute: T): boolean; overload;
    class function GetAttribute<T>(ARttiType: TRttiType): T; overload;
    class function GetAttribute<T>(ARttiType: TRttiType; out Attribute: T):
        boolean; overload;
    class function GetAttributes<T>(ARttiNamedObject: TRttiNamedObject; var
        Attributes: TArray<T>): boolean; overload;
    class function GetAttributes<T>(ARttiType: TRttiType; var Attributes:
        TArray<T>): boolean; overload;
    function Serialize(ASerializerClass: TgSerializerClass; ADefaultClass: TgBaseClass): String; overload; virtual;
    function Serialize(ASerializerClass: TgSerializerClass): String; overload; virtual;
    function GetPathIndexOf(const APath: String): Integer; virtual;
    class function RTTIValueProperties: TArray<TRTTIProperty>; virtual;
    //1 This gets the display title for a property
    property Captions[const AName: String]: String read GetCaptions;
    property Helps[const AName: String]: String read GetHelps;
    property IsAutoCreating: Boolean index osAutoCreating read GetStates write SetStates;
    property IsInspecting: Boolean index osInspecting read GetStates write SetStates;
    property IsLoaded: Boolean index osLoaded read GetStates write SetStates;
    ///	<summary>
    ///	  This property is used to get and set values for any published
    ///	  property on this structure or any <see cref="TgBase" /> structure
    ///	  owned by a published class property
    ///	</summary>
    ///	<param name="APath">
    ///	  Local properties are just their name, but when using this on a
    ///	  <see cref="TgBase" /> class decendant
    ///	</param>
    property Values[Const APath : String]: Variant read GetValues write SetValues; default;
    ///	<summary>
    ///	  This property is used to get and set Objects for any published
    ///	  property on this structure or any <see cref="TgBase" /> structure
    ///	  owned by a published class property
    ///	</summary>
    ///	<param name="APath">
    ///	  Local properties are just their name, but when using this on a
    ///	  <see cref="TgBase" /> class decendant
    ///	</param>
    property Objects[Const APath : String]: TgBase read GetObjects;
    ///	<summary>
    ///	  This property is used to get and set Properties for any published
    ///	  property on this structure or any <see cref="TgBase" /> structure
    ///	  owned by a published class property
    ///	</summary>
    ///	<param name="APath">
    ///	  Local properties are just their name, but when using this on a
    ///	  <see cref="TgBase" /> class decendant
    ///	</param>
    property Properties[Const APath : String]: TRTTIProperty read GetProperties;
    property PathCount: Integer read GetPathCount;
    property Paths[Index: Integer]: String read GetPaths;
    property PathValues[Index: Integer]: TPathValue read GetPathValues;
    function UseRestPath(const Path: String; var TemplateName: String; out gBase: TgBase; const Delim: char = '/'): Boolean;
  published
    [NotSerializable] [NotVisible]
    property FriendlyClassName: String read GetFriendlyClassName;
    [NotAutoCreate] [NotComposite] [NotSerializable] [NotVisible] [NotAssignable]
    property Model: TgModel read GetModel;

    /// <summary>TgBase.Owner represents the object passed in the constructor. You may
    /// use the Owner object to "walk up" the model.
    /// </summary> type:TgBase
    [NotAutoCreate] [NotComposite] [NotSerializable] [NotVisible] [NotAssignable]
    property Owner: TgBase read FOwner;
  end;

  TgList<T: TgBase> = class;



  ///	<summary>
  ///	  G Class is used to cache all RTTI information for clases that decend
  ///	  from the <see cref="TgBase" />.  It keeps the RTTI information and
  ///	  properties in a optimal format for some of the standard routines used
  ///	  by <see cref="TgBase" />, <see cref="TgSerializer" />, and <see cref="TgPersistenceManager" />.
  ///	</summary>
  G = class(TObject)
  public
    type
      TgBaseClassComparer = class(TComparer<TRTTIType>)
        function Compare(const Left, Right: TRTTIType): Integer; override;
      end;

      TgRecordProperty = Record
      public
        Getter: TRTTIMethod;
        Setter: TRTTIMethod;
        Validator: TRTTIMethod;
      End;

      TgPropertyValidationAttribute = record
      public
        RTTIProperty: TRTTIProperty;
        ValidationAttribute: Validation;
        procedure Execute(AObject: TgObject);
      End;

      TgPropertyAttributeClassKey = record
      public
        AttributeClass: TCustomAttributeClass;
        RTTIProperty: TRTTIProperty;
        constructor Create(ARTTIProperty: TRttiProperty; AAttributeClass: TCustomAttributeClass);
      end;

      TgIdentityObjectClassProperty = record
      public
        IdentityObjectClass: TgIdentityObjectClass;
        RTTIProperty: TRTTIProperty;
        constructor Create(AIdentityObjectClass: TgIdentityObjectClass; ARTTIProperty: TRTTIProperty);
      end;
      TSpecialFolder = (sfCommonAppData);

  strict private
  class var
    FAssignableProperties: TDictionary<TgBaseClass, TArray<TRTTIProperty>>;
    FAttributes: TDictionary<TPair<TgBaseClass, TCustomAttributeClass>, TArray<TCustomAttribute>>;
    FAutoCreateProperties: TDictionary<TgBaseClass, TArray<TRTTIProperty>>;
    FCompositeProperties: TDictionary<TgBaseClass, TArray<TRTTIProperty>>;
    FDisplayPropertyNames: TDictionary<TgBaseClass, TArray<String>>;
    FMethodByName: TDictionary<String, TRTTIMethod>;
    FObjectProperties: TDictionary<TgBaseClass, TArray<TRTTIProperty>>;
    FPersistableProperties: TDictionary<TgBaseClass, TArray<TRTTIProperty>>;
    FProperties: TDictionary<TgBaseClass, TArray<TRTTIProperty>>;
    FPropertyByName: TDictionary<String, TRTTIProperty>;
    FPropertyValidationAttributes: TDictionary<TgBaseClass, TArray<TgPropertyValidationAttribute>>;
    FRecordProperty: TDictionary<TRTTIProperty, TgRecordProperty>;
    FRTTIContext: TRTTIContext;
    FSerializableProperties: TDictionary < TgBaseClass, TArray < TRTTIProperty >>;
    FSerializationHelpers: TDictionary<TgSerializerClass, TList<TPair<TgBaseClass, TgSerializationHelperClass>>>;
    FClassValidationAttributes: TDictionary<TgBaseClass, TArray<Validation>>;
    FConnectionDescriptors: TDictionary<String, TgConnectionDescriptor>;
    FListProperties: TDictionary<TgBaseClass, TArray<TRTTIProperty>>;
    FOwnedAttributes: TObjectList;
    FPersistenceManagers: TDictionary<TgIdentityObjectClass, TgPersistenceManager>;
    FPropertyAttributes: TDictionary<TgPropertyAttributeClassKey, TArray<TCustomAttribute>>;
    FVisibleProperties: TDictionary<TgBaseClass, TArray<TRTTIProperty>>;
    FIdentityListProperties: TDictionary<TgBaseClass, TArray<TRTTIProperty>>;
    FReferences: TDictionary<TgIdentityObjectClass, TArray<TgIdentityObjectClassProperty>>;
    FServers: TDictionary<String, TgServer>;
    class procedure InitializeAssignableProperties(ARTTIType: TRTTIType); static;
    /// <summary>G.InitializeAttributes initializes the cache of attributes for the
    /// class passed in the ARTTIType parameter.  For property attributes, it assigns
    /// the attribute's RTTIProperty property.
    /// </summary>
    /// <param name="ARTTIType"> (TRTTIType) </param>
    class procedure InitializeAttributes(ARTTIType: TRTTIType); static;
    class procedure InitializeDisplayPropertyNames(ARTTIType: TRTTIType); static;
    class procedure InitializeMethodByName(ARTTIType: TRTTIType); static;
    class procedure InitializeObjectProperties(ARTTIType: TRTTIType); static;
    class procedure InitializePersistenceManager(ARTTIType: TRTTIType); static;
    class procedure InitializeProperties(ARTTIType: TRTTIType); static;
    class procedure InitializePropertyByName(ARTTIType: TRTTIType); static;
    class procedure InitializeRecordProperty(ARTTIType: TRTTIType); static;
    class procedure InitializeSerializationHelpers(ARTTIType: TRTTIType); static;
    class procedure InitializeAutoCreate(ARTTIType: TRTTIType); static;
    class procedure InitializeCompositeProperties(ARTTIType: TRTTIType); static;
    class procedure InitializeSerializableProperties(ARTTIType: TRTTIType); static;
    class procedure InitializeVisibleProperties(ARTTIType: TRTTIType); static;
    class procedure InitializePersistableProperties(ARTTIType: TRTTIType); static;
    class procedure InitializePropertyValidationAttributes(ARTTIType: TRTTIType); static;
  public
    class var
      DefaultPersistenceManagerClassName: String;
    class var
      _AfterInit: array of TProc;
    class constructor Create;
    class destructor Destroy;
    class procedure AfterInit(Proc: TProc);
    class procedure DoAfterInit;
    class procedure AddConnectionDescriptor(AConnectionDescriptor: TgConnectionDescriptor); static;
    class procedure AddServer(AServer: TgServer); static;
    class function SpecialFolder(Index: TSpecialFolder): String;
    class function RootPath: String; static;
    class function ApplicationPath(ABaseClass: TgBaseClass): String;
    class function AssignableProperties(ABaseClass: TgBaseClass): TArray<TRTTIProperty>; overload; static;
    class function AssignableProperties(ABase: TgBase): TArray<TRTTIProperty>; overload; static;
    class function Attributes(ABaseClass: TgBaseClass; AAttributeClass: TCustomAttributeClass): TArray<TCustomAttribute>; overload; static;
    class function Attributes(ABase: TgBase; AAttributeClass: TCustomAttributeClass): Tarray<TCustomAttribute>; overload; static;
    class function AutoCreateProperties(AInstance: TgBase): TArray<TRTTIProperty>; overload; static; inline;
    class function AutoCreateProperties(AClass: TgBaseClass): TArray<TRTTIProperty>; overload; static;
    class function ClassByName(const AName: String): TgBaseClass; static;
    class function CompositeProperties(AClass: TgBaseClass): TArray<TRTTIProperty>; overload; static;
    class function CompositeProperties(ABase: TgBase): TArray<TRTTIProperty>; overload; static;
    class function DisplayPropertyNames(AClass: TgBaseClass): TArray<String>; static;
    class function MethodByName(ABaseClass: TgBaseClass; const AName: String): TRTTIMethod; overload; static;
    class function MethodByName(ABase: TgBase; const AName: String): TRTTIMethod; overload; static;
    class function ObjectProperties(AInstance: TgBase): TArray<TRTTIProperty>; overload; static; inline;
    class function ObjectProperties(AClass: TgBaseClass): TArray<TRTTIProperty>; overload; static; inline;
    class function PersistableProperties(ABaseClass: TgBaseClass): TArray<TRTTIProperty>; overload; static;
    class function PersistableProperties(ABase: TgBase): TArray<TRTTIProperty>; overload; static;
    class function Properties(AClass: TgBaseClass): TArray<TRTTIProperty>; static;
    class function PropertyByName(AClass: TgBaseClass; const AName: String): TRTTIProperty; overload; static;
    class function PropertyByName(ABase: TgBase; const AName: String): TRTTIProperty; overload; static;
    class function PropertyValidationAttributes(ABaseClass: TgBaseClass): TArray<TgPropertyValidationAttribute>; overload; static;
    class function PropertyValidationAttributes(ABase: TgBase): TArray<TgPropertyValidationAttribute>; overload; static;
    class function RecordProperty(ARTTIProperty: TRTTIProperty): TgRecordProperty; static;
    class function SerializableProperties(ABase: TgBase): TArray<TRTTIProperty>; overload; inline;
    class function SerializableProperties(AClass : TgBaseClass): TArray<TRTTIProperty>; overload;
    class function SerializationHelpers(ASerializerClass: TgSerializerClass; AObject: TgBase): TgSerializationHelperClass; static;
    class function ClassValidationAttributes(AClass: TgBaseClass): TArray<Validation>; overload; static;
    class function ClassValidationAttributes(ABase: TgBase): TArray<Validation>; overload; static;
    class function ConnectionDescriptor(const AName: String): TgConnectionDescriptor; static;
    class function DataPath(ABaseClass: TgBaseClass): String; overload; static;
    class function DataPath: String; overload; static;
    class procedure Finalize;
    class function IdentityListProperties(ABaseClass: TgBaseClass): TArray<TRTTIProperty>; overload; static;
    class function IdentityListProperties(ABase: TgBase): TArray<TRTTIProperty>; overload; static;
    class procedure Initialize; static;
    class function IsComposite(ARTTIProperty: TRTTIProperty): Boolean; static;
    class procedure LoadPackages(const APackageNames: TArray<String>); overload;
    class procedure LoadPackages(APackageNames: TStrings); overload;
    class function PersistenceManagerPath: String; static;
    class function PersistenceManager(AIdentityObjectClass: TgIdentityObjectClass): TgPersistenceManager; static;
    class function PersistenceManagers: TDictionary<TgIdentityObjectClass, TgPersistenceManager>.TValueCollection; static;
    class function PropertyAttributes(APropertyAttributeClassKey: TgPropertyAttributeClassKey): TArray<TCustomAttribute>; static;
    class function References(AIdentityObjectClass: TgIdentityObjectClass): TArray<TgIdentityObjectClassProperty>; overload; static;
    class function References(AIdentityObject: TgIdentityObject): TArray<TgIdentityObjectClassProperty>; overload; static;
    class function Server(const AName: String): TgServer; static;
    class function VisibleProperties(ABaseClass: TgBaseClass): TArray<TRTTIProperty>; static;
  end;

  TgSerializationHelper<gBase: TgBase; gSerializer: TgSerializer> = class(TgSerializer.THelper)
  public
    type
      E = class(Exception);
  public
    class function SerializerClass: TgSerializerClass; override;
    class function BaseClass: TgBaseClass; override;
    class procedure Serialize(AObject: TgBase; ASerializer: TgSerializer; ARTTIProperty: TRTTIProperty = Nil); overload; override;
    class procedure Serialize(AObject: gBase; ASerializer: gSerializer; ARTTIProperty: TRTTIProperty = Nil); reintroduce; overload;  virtual; abstract;
    class procedure Deserialize(AObject: TgBase; ASerializer: TgSerializer; ARTTIProperty: TRTTIProperty = Nil); overload; override;
    class procedure Deserialize(AObject: gBase; ASerializer: gSerializer; ARTTIProperty: TRTTIProperty = Nil); reintroduce; overload;  virtual; abstract;
    class procedure DeserializeUnpublishedProperty(AObject: TgBase; ASerializer: TgSerializer; const PropertyName: String); overload; override;
    class procedure DeserializeUnpublishedProperty(AObject: gBase; ASerializer: gSerializer; const PropertyName: String); reintroduce; overload;  virtual;
  end;

  TgSerializationHelper = TgSerializer.THelper; // This declaration is used for generic types removing the . notatation

  EgParse = class(Exception)
  end;

  ///	<summary>
  ///	  This class will be used to cursor through a FList of
  ///	  <see cref="gCore|TgBase" /> classes and will also be used to support
  ///	  selection lists in the user Interface
  ///	</summary>
  ///	<remarks>
  ///	  <para>
  ///	    This maintains a cursor in the FList of
  ///	    <see cref="gCore|TgList.Current">Current</see> and can be moved by
  ///	    setting the <see cref="gCore|TgList.CurrentIndex">CurrentIndex</see>,
  ///	    and the Count Property will tell you how many items are in the FList
  ///	  </para>
  ///	  <para>
  ///	    Filtering is achived by using the
  ///	    <see cref="gCore|TgList.Where">Where</see> property and Sorting can
  ///	    be achived by setting the
  ///	    <see cref="gCore|TgList.OrderBy">OrderBy</see> property.
  ///	  </para>
  ///	  <para>
  ///	    To Check status or Change the Current  Item use:
  ///	  </para>
  ///	  <para>
  ///	    <ul><li><see cref="gCore|TgList.First">First</see></li><li><see cref="gCore|TgList.Last">Last</see></li><li><see cref="gCore|TgList.Next">Next</see>, <see cref="gCore|TgList.CanNext">CanNext</see>, <see cref="gCore|TgList.EOL">EOL</see></li><li><see cref="gCore|TgList.Previous">Previous</see>, <see cref="gCore|TgList.CanPrevious">CanPrevious</see>,
  ///	    <see cref="gCore|TgList.BOL">BOL</see></li><li><see cref="gCore|TgList.HasItems">HasItems</see></li>
  ///     </ul>
  ///	  </para>
  ///	  <para>
  ///	    To use Add to append a new item or Delete to remove the current Item
  ///	  </para>
  ///	</remarks>
 ///  <seealso cref="gCore|TgList{T}" />
  TgList = class(TgBase)
    Type
      TClassOf = class of TgList;
      TgOrderByItem = class(TObject)
      public
        type
          EgOrderByItem = class(Exception);
      strict private
        FDescending: Boolean;
        FPropertyName: String;
      public
        constructor Create(const AItemText: String);
        property Descending: Boolean read FDescending write FDescending;
        property PropertyName: String read FPropertyName write FPropertyName;
      end;

      /// <summary> Structure used by the <see cref="GetEnumerator" /> to allow For-in
      /// loops</summary>
      TgEnumerator = record
      private
        FCurrentIndex: Integer;
        FList: TgList;
        function GetCurrent: TgBase;
      public
        procedure Init(AList: TgList);
        function MoveNext: Boolean;
        property Current: TgBase read GetCurrent;
      End;

      /// <summary> Internal structure used by the <see cref="OrderBy" />  to sort the items contained in this FList
      /// </summary>
      TgComparer = class(TComparer<TgBase>)
      strict private
        FOrderByList: TObjectList<TgOrderByItem>;
      public
        constructor Create(AOrderByList: TObjectList<TgOrderByItem>);
        function Compare(const Left, Right: TgBase): Integer; override;
      end;

  strict private
    FItemClass: TgBaseClass;
    FOrderBy: String;
    FOrderByList: TObjectList<TgOrderByItem>;
    FWhere: String;
    FCurrentIndex: Integer;
    function GetIsFiltered: Boolean;
    function GetIsOrdered: Boolean;
    function GetOrderByList: TObjectList<TgOrderByItem>;
    procedure SetIsFiltered(const AValue: Boolean);
    procedure SetIsOrdered(const AValue: Boolean);
  strict protected
    FList: TObjectList<TgBase>;
    function DoGetValues(Const APath : String; Out AValue : Variant): Boolean; override;
    function DoSetValues(Const APath : String; AValue : Variant): Boolean; override;
    function GetBOL: Boolean; virtual;
    function GetCanAdd: Boolean; virtual;
    function GetCanNext: Boolean; virtual;
    function GetCanPrevious: Boolean; virtual;
    function GetCount: Integer; virtual;
    function GetCurrent: TgBase; virtual;
    function GetCurrentIndex: Integer; virtual;
    function GetEOL: Boolean; virtual;
    function GetHasItems: Boolean; virtual;
    function GetIndexString: String; virtual;
    function GetItemClass: TgBaseClass; virtual;
    function GetItems(AIndex : Integer): TgBase; virtual;
    procedure SetCurrentIndex(const AIndex: Integer); virtual;
    procedure SetIndexString(const AValue: String); virtual;
    procedure SetItemClass(const Value: TgBaseClass); virtual;
    procedure SetItems(AIndex : Integer; const AValue: TgBase); virtual;
    procedure SetOrderBy(const AValue: String); virtual;
    procedure SetWhere(const AValue: String); virtual;
    function DoGetObjects(const APath: string; out AValue: TgBase): Boolean;
      override;
  protected
    function GetObjectChildPathName(AChild: TgBase = nil): string; override;
    function DoUseRestPath(const Path: string; var TemplateName: string;
      out gBase: TgBase; const Delim: char = '/'): Boolean; override;
    function RestKeyToIndex(const Key: String; out Index: Integer): boolean; virtual;
  public
    type
      /// <summary> This is the general exception for a <see cref="TgList" />
      /// </summary>
      EgList = class(Exception);
    class function _ItemClass: TgBaseClass; virtual;
    constructor Create(AOwner: TgBase = Nil); override;
    destructor Destroy; override;
    procedure Assign(ASource: TgBase); override;
    procedure Clear; virtual;

    ///	<summary>
    ///	  In combination with the <see cref="where" /> property this will create a sub FList of
    ///	  the main FList to cursor through.
    ///	</summary>
    procedure Filter; virtual;
    function GetEnumerator: TgEnumerator;
    procedure Sort;
    procedure Add(const AItemClassName: String); overload;
    procedure Add(AItemClass: TgBaseClass); overload;
    property IndexString: String read GetIndexString write SetIndexString;
    property IsFiltered: Boolean read GetIsFiltered write SetIsFiltered;
    property IsOrdered: Boolean read GetIsOrdered write SetIsOrdered;
    property ItemClass: TgBaseClass read GetItemClass write SetItemClass;
    property Items[AIndex : Integer]: TgBase read GetItems write SetItems; default;
    property OrderByList: TObjectList<TgOrderByItem> read GetOrderByList;
  published
    procedure Add; overload; virtual;
    procedure Delete; virtual;
    procedure First; virtual;
    procedure Last; virtual;
    procedure Next; virtual;
    procedure Previous; virtual;
    property BOL: Boolean read GetBOL;
    property CanAdd: Boolean read GetCanAdd;
    property CanNext: Boolean read GetCanNext;
    property CanPrevious: Boolean read GetCanPrevious;
    property Count: Integer read GetCount;
    [NotAutoCreate] [NotSerializable] [NotAssignable]
    property Current: TgBase read GetCurrent;
    [NotSerializable] [NotAssignable]
    property CurrentIndex: Integer read GetCurrentIndex write SetCurrentIndex;
    property EOL: Boolean read GetEOL;
    property HasItems: Boolean read GetHasItems;
    [NotSerializable]
    property OrderBy: String read FOrderBy write SetOrderBy;
    ///	<summary>
    ///	  After setting this property with a proper value you'll need to use
    ///	  the <see cref="Filter" /> method to create the new filtered FList
    ///	</summary>
    /// <example>
    ///	  <code lang="Delphi">
    ///  type
    ///    TgMine = class(TgCore)
    ///    private
    ///      FID: Integer;
    ///    published
    ///      property ID: Integer read FID write FID;
    ///    end;
    ///	 var FList: TgList;
    ///  begin
    ///    FList := TgList;
    ///    FList.ItemClass := TgMine;
    ///    FList.Where := 'ID = 12';
    ///    FList.Filter;
    ///    FList.Free;
    ///  end;
    ///	  </code>
    /// </example>
    [NotSerializable]
    property Where: String read FWhere write SetWhere;
  end;


 ///	<summary>
 ///	  Decendant class of <see cref="gCore|TgList" /> but the
 ///	  <see cref="gCore|TgList{T}.Current">Current</see>
 ///	  property as well as the for in operator will be native types
 ///	  of T as well as introducing a <see cref="gCore|TgList{T}.Items">Items</see> property
 ///	</summary>
 ///	<typeparam name="T">
 ///	  would be the decendant class of <see cref="gCore|TgBase">TgBase</see> to be Managed by this list
 ///	</typeparam>
 ///  <seealso cref="gCore|TgList">TgList</seealso>
 TgList<T: TgBase> = class(TgList)
  Public
    type
      EgList = class(Exception);

      /// <summary> Structure used by the <see cref="GetEnumerator" /> to allow For-in
      /// loops.</summary>
      /// <remarks> This Enumerator is necessary because of the generic type of the <see
      /// cref="TgList{T}" />
      ///
      /// </remarks>
      TgEnumerator = record
      private
        FCurrentIndex: Integer;
        FList: TgList<T>;
        function GetCurrent: T;
      public
        procedure Init(AList: TgList<T>);
        function MoveNext: Boolean;
        property Current: T read GetCurrent;
      End;
  strict
  private
    procedure SetItemClass(const Value: TgBaseClass); override;
    function GetCurrent: T; reintroduce; virtual;
    function GetItems(AIndex : Integer): T; reintroduce; virtual;
    procedure SetItems(AIndex : Integer; const AValue: T); reintroduce; virtual;
  Public
    function GetEnumerator: TgEnumerator;
    class function AddAttributes(ARTTIProperty: TRttiProperty): System.TArray<TSystemCustomAttribute>; override;
    constructor Create(AOwner: TgBase = nil); override;
    class function _ItemClass: TgBaseClass; override;
    property Items[AIndex : Integer]: T read GetItems write SetItems; default;
  Published
    property Current: T read GetCurrent;
  End;

  TgOriginalValues = class(TgBase)
  private
    FValues: array of Variant;
  public
    procedure Load;
    function DoGetValues(const APath: string; out AValue: Variant): Boolean; overload; override;
  end;

  TgObjectClass = class of TgObject;
  TgObject = class(TgBase)
  public
    type
      ///	<summary>
      ///	  Used to collectect validation errors when a
      ///	  <see cref="TgObject" />'s published
      ///	  properties are validated
      ///	</summary>
      TgValidationErrors = class(TgBase)
      strict private
        FDictionary: TDictionary<String, String>;
        function GetCount: Integer;
        function GetHasItems: Boolean;
      strict protected
        function DoGetValues(const APath: string; out AValue: Variant): Boolean; override;
        function DoSetValues(const APath: string; AValue: Variant): Boolean; override;
      public
        constructor Create(AOwner: TgBase = Nil); override;
        destructor Destroy; override;
        procedure Clear;
        procedure PopulateList(AStringList: TStrings);
      published
        property Count: Integer read GetCount;
        property HasItems: Boolean read GetHasItems;
      end;
  strict private
    FValidationErrors: TgValidationErrors;
    FOriginalValues: TgOriginalValues;
    function GetOriginalValues: TgOriginalValues; overload;
    function GetValidationErrors: TgValidationErrors;
    procedure PopulateDefaultValues;
  strict protected
    function GetDisplayName: String; virtual;
    function GetIsValid: Boolean; virtual;
    procedure GetIsValidInternal; virtual;
  public
    constructor Create(AOwner: TgBase = nil); override;
    destructor Destroy; override;
    function AllValidationErrors: String;
    class function DisplayPropertyNames: TArray<String>; inline;
    function HasValidationErrors: Boolean;
    procedure InitializeOriginalValues; virtual;
    property IsCreatingOriginalValues: Boolean index osCreatingOriginalValues read
        GetStates write SetStates;
    property IsOriginalValues: Boolean index osOriginalValues read GetStates write
        SetStates;
    ///	<summary>
    ///	  When the value of this property is requested it will run all
    ///	  properties through their <see cref="Validation" /> attributes to ensure they properties are valid
    ///	</summary>
    property IsValid: Boolean read GetIsValid;
  published
    [NotVisible]
    property DisplayName: String read GetDisplayName;
    ///	<summary>
    ///	  The purpose of the OriginalValues is to determine the values that have
    /// changed since the object was loaded for the purposes of updating just the
    /// values that have changed.  Its the job of the load to clone values in
    /// original values.
    ///  In saving, it should compare original values to know what changed and only
    /// write the diffrerce
    ///  example: in code, i loaded a object, modified and hit save. in the save
    /// process, it should load the original structure, and only change the
    /// values from the original structure that where changed from original values.
    ///  In SQL you wouldn't have to load the original stucture.
    ///
    ///  Load the object, it disappears, post the change. durring the post the
    /// original values will be loaded from the post
    ///	</summary>
    [NotAutoCreate] [NotComposite] [NotSerializable] [NotAssignable] [NotVisible]
    property OriginalValues: TgOriginalValues read GetOriginalValues;
    [NotAutoCreate] [NotComposite] [NotSerializable] [NotAssignable] [NotVisible]
    property ValidationErrors: TgValidationErrors read GetValidationErrors;
  end;

  { TODO -oJim -cDefinations : I'm not clear what the defination of this attribute would be, and what it is used for }
  DisplayPropertyNames = class(TCustomAttribute)
  strict private
    FValue: TArray<String>;
  public
    constructor Create(AValue: TArray<String>);
    property Value: TArray<String> read FValue;
  end;

  EgValidation = class(Exception)
  end;

  ///	<summary>
  ///	  The TgPersistenceManager is the base class for storing and retreving
  ///	  Decendants of <see cref="TgIdentityObject" /> via their published
  ///	  properties. 
  ///	</summary>
  TgPersistenceManager = class(TgObject)
  strict private
    FForClass: TgIdentityObjectClass;
  public
    procedure ActivateList(AIdentityList: TgIdentityList); virtual; abstract;
    procedure Commit(AObject: TgIdentityObject); virtual; abstract;
    procedure Configure; virtual;
    function Count(AIdentityList: TgIdentityList): Integer; virtual; abstract;
    procedure CreatePersistentStorage; virtual; abstract;
    procedure DeleteObject(AObject: TgIdentityObject); virtual; abstract;
    procedure Initialize; virtual;
    procedure LoadObject(AObject: TgIdentityObject); virtual; abstract;
    function PersistentStorageExists: Boolean; virtual; abstract;
    procedure RollBack(AObject: TgIdentityObject); virtual; abstract;
    procedure SaveObject(AObject: TgIdentityObject); virtual; abstract;
    procedure StartTransaction(AObject: TgIdentityObject; ATransactionIsolationLevel: TgTransactionIsolationLevel = ilReadCommitted); virtual; abstract;
    function FileName: String;
    property ForClass: TgIdentityObjectClass read FForClass write FForClass;
  End;

  ///	<summary>
  ///	  This class is used for <see cref="TgPersistenceManager" />.  It
  ///	  contains a property <see cref="ID" /> which is the key used to store
  ///	  the published properties of this class.  If you plan or persisting to a
  ///	  database you should actually decend from <see cref="TgIdentityObject&lt;T&gt;" />
  ///	</summary>
  TgIdentityObject = class(TgObject)

    type
      E = Class(Exception)
      End;

  strict private
    FID: Variant;
  strict protected
    procedure DoDelete; virtual;
    procedure DoLoad; virtual;
    procedure DoSave; virtual;
    function GetCanDelete: Boolean; virtual;
    function GetCanSave: Boolean; virtual;
    function GetID: Variant;
    function GetIsModified: Boolean; virtual;
    procedure SetID(const AValue: Variant);
    procedure SetStates(const AIndex: TgBase.TState; const AValue: Boolean);
      override;
  protected
    function GetObjectChildPathName(AChild: TgBase = nil): string; override;
  public
    procedure Commit;
    function IsPropertyModified(const APropertyName: string): Boolean; overload;
    function IsPropertyModified(ARTTIProperty: TRttiProperty): Boolean; overload;
    class function PersistenceManager: TgPersistenceManager;
    procedure Rollback;
    procedure StartTransaction(ATransactionIsolationLevel: TgTransactionIsolationLevel = ilReadCommitted);
    procedure Assign(ASource: TgBase); reintroduce; override;
    function HasIdentity: Boolean; virtual;
    procedure RemoveIdentity;
    class function PersistenceManagerPath: String;
    constructor Create(AOwner: TgBase = nil); override;
    property IsDeleting: Boolean index osDeleting read GetStates write SetStates;
    property IsLoading: Boolean index osLoading read GetStates write SetStates;
    property IsModified: Boolean read GetIsModified;
    property IsSaving: Boolean index osSaving read GetStates write SetStates;
  published
    [NotVisible]
    property ID: Variant read GetID write SetID;
    [NotVisible]
    property CanDelete: Boolean read GetCanDelete;
    [NotVisible]
    property CanSave: Boolean read GetCanSave;
    procedure Delete; virtual;
    [NotVisible]
    function Load: Boolean; virtual;
    procedure Save; virtual;

  end;

  ///	<summary>
  ///	  This class serves the same purpose as <see cref="TgIdentityObject" />
  ///	  the exception that <see cref="T" /> is used to clearly define the type 
  ///	  of the <see cref="ID" /> property which will be used some
  ///	  <see cref="TgPersistenceManager" /> decendants like sql to know what to
  ///	  define the type of field as in the table.
  ///	</summary>
  ///	<typeparam name="T">
  ///	  This type should be limited to Simple types
  ///	</typeparam>
  TgIdentityObject<T> = class(TgIdentityObject)
  public
    type
      E = class(exception);
  strict protected
    function GetID: T;
    procedure SetID(const AValue: T);
    class var T_TypeInfo: pTypeInfo;
    class constructor Create;
  protected
  published
    ///	<summary>
    ///	  Defined as a simple type this property is used to uniquely identify a
    ///	  class in the Persistance Manager so the classes properties can be
    ///	  saved and retrived
    ///	</summary>
    [NotVisible]
    property ID: T read GetID write SetID;
  end;

  ///	<summary>
  ///	  This class is used to make the <see cref="TgIdentityObject{T}.ID">ID</see> property a Integer
  ///	</summary>
  TgIDObject = class(TgIdentityObject<Integer>)
  public
    constructor Create(AOwner: TgBase = nil); override;
  end;

  ///	<summary>
  ///	  This <see cref="TgPeristanceManager" /> decendant is used to stream
  ///	  <see cref="TgIdentityObject" /> decendatants in and out of a file.  It
  ///	  will use the <see cref="TgSerializerXML" />.
  ///	</summary>
  ///	<remarks>
  ///	  This file will be kept in the jason format in the ..\data folder from
  ///	  where the application is running from
  ///	</remarks>
  TgPersistenceManagerFile = class(TgPersistenceManager)

    type
      E = class(Exception)
      end;

      ///	<summary>
      ///	  <see cref="TList" /> is used to load and save <see cref="TgIdentityObject" />s in the <see cref="TgPersistenceManagerFile" />.  it manages the <see cref="TgIdentityObject.ID">ID</see> Property using the <see cref="LastID" /> when there is a new class to be added to the file
      ///	</summary>
      TList = class(TgList<TgIdentityObject>)
      strict private
        FLastID: Integer;
      published
        ///	<summary>
        ///	  LastID is used as a AutoIncrement value for adding new classes to
        ///	  the PersistenceFile
        ///	</summary>
        property LastID: Integer read FLastID write FLastID;
      end;

  strict private
    procedure AssignChanged(ASourceObject, ADestinationObject: TgIdentityObject);
    function Filename: String;
    procedure LoadList(const AList: TgPersistenceManagerFile.TList);
    function Locate(const AList: TgPersistenceManagerFile.TList; AObject: TgIdentityObject): Boolean;
    procedure SaveList(const AList: TgPersistenceManagerFile.TList);
  public
    procedure Commit(AObject: TgIdentityObject); override;
    procedure StartTransaction(AObject: TgIdentityObject; ATransactionIsolationLevel: TgTransactionIsolationLevel = ilReadCommitted); override;
    procedure RollBack(AObject: TgIdentityObject); override;
    procedure LoadObject(AObject: TgIdentityObject); override;
    procedure SaveObject(AObject: TgIdentityObject); override;
    procedure DeleteObject(AObject: TgIdentityObject); override;
    procedure ActivateList(AIdentityList: TgIdentityList); override;
    function PersistentStorageExists: Boolean; override;
    procedure CreatePersistentStorage; override;
    function Count(AIdentityList: TgIdentityList): Integer; override;
  end;

  TgIdentityList = class(TgList)

    Type
      TgEnumerator = record
      private
        FCurrentIndex: Integer;
        FList: TgList;
        function GetCurrent: TgIdentityObject;
      public
        procedure Init(AList: TgList);
        function MoveNext: Boolean;
        property Current: TgIdentityObject read GetCurrent;
      End;

  strict private
    FCurrentKey: String;
    FBuffered: Boolean;
    procedure EnsureActive;
  strict protected
    procedure SetActive(const AValue: Boolean); virtual;
    function GetActive: Boolean; virtual;
    function GetBOL: Boolean; override;
    function GetEOL: Boolean; override;
    function GetCount: Integer; override;
    function GetCurrent: TgIdentityObject; reintroduce; virtual;
    function GetCurrentKey: String; virtual;
    function GetItemClass: TgIdentityObjectClass; reintroduce; virtual;
    function GetItems(AIndex : Integer): TgIdentityObject; reintroduce; virtual;
    procedure SetCurrentKey(const AValue: String); virtual;
    procedure SetItemClass(const Value: TgIdentityObjectClass); reintroduce; virtual;
    procedure SetItems(AIndex : Integer; const AValue: TgIdentityObject); reintroduce; virtual;
    function GetIndexString: string; override;
    procedure SetIndexString(const AValue: String); override;
    procedure SetWhere(const AValue: string); override;
    procedure SetCurrentIndex(const AIndex: Integer); override;
  public
    procedure Assign(ASource: TgBase); override;
    procedure AssignActive(const AValue: Boolean);
    function ExtendedWhere: String; virtual;
    function GetEnumerator: TgEnumerator;
    procedure Save; virtual;
    function IndexOf(const AKey: String): Integer;
    property Active: Boolean read GetActive write SetActive;
    property Buffered: Boolean read FBuffered write FBuffered;
    property IsActivating: Boolean index osActivating read GetStates write SetStates;
    property ItemClass: TgIdentityObjectClass read GetItemClass write SetItemClass;
    property Items[AIndex : Integer]: TgIdentityObject read GetItems write SetItems; default;
  published
    procedure First; override;
    procedure Last; override;
    procedure Next; override;
    procedure Previous; override;
    procedure Delete; override;
    [NotAutoCreate] [NotSerializable] [NotAssignable]
    property Current: TgIdentityObject read GetCurrent;
    [NotSerializable] [NotAssignable]
    property CurrentKey: String read GetCurrentKey write SetCurrentKey;
  end;

  TgIdentityList<T: TgIdentityObject> = class(TgIdentityList)
  type
    TgEnumerator = record
    strict private
      function GetCurrentOriginalValues: TgOriginalValues;
    private
      FCurrentIndex: Integer;
      FList: TgIdentityList<T>;
      function GetCurrent: T;
    public
      procedure Init(AList: TgIdentityList<T>);
      function MoveNext: Boolean;
      property Current: T read GetCurrent;
      property CurrentOriginalValues: TgOriginalValues read GetCurrentOriginalValues;
    End;

  strict protected
    function GetCurrent: T; reintroduce; virtual;
    function GetItems(AIndex : Integer): T; reintroduce; virtual;
    procedure SetItems(AIndex : Integer; const AValue: T); reintroduce; virtual;
  public
    class function _ItemClass: TgBaseClass; override;
    class function AddAttributes(ARTTIProperty: TRttiProperty): System.TArray<TSystemCustomAttribute>; override;
    function GetEnumerator: TgEnumerator;
    constructor Create(AOwner: TgBase = nil); override;
    function TryGet(const Key: String; out Item: T): Boolean;
    property Items[AIndex : Integer]: T read GetItems write SetItems; default;
  published
    property Current: T read GetCurrent;
  end;

  [DenyDelete]
  TgIdentityListDenyDelete<T: TgIdentityObject> = class(TgIdentityList<T>)
  end;

  [CascadeDelete]
  TgIdentityListCascadeDelete<T: TgIdentityObject> = class(TgIdentityList<T>)
  end;

  TgDictionary = class(TgBase)
  strict private
    FDictionary: TDictionary<String, Variant>;
  strict protected
    function DoGetValues(const APath: string; out AValue: Variant): Boolean; override;
    function DoSetValues(const APath: string; AValue: Variant): Boolean; override;
    function GetPathCount: Integer; override;
    function GetPaths(AIndex: Integer): String; override;
  public
    procedure Delete(const APath: String);
    constructor Create(AOwner: TgBase = Nil); override;
    destructor Destroy; override;
  end;

  TgSerializerStackBase<T> = class(TgSerializer)
  public
    type
      TProcedure = reference to procedure;
  strict protected
    FNodeStack: TStack<T>;
    function GetCurrentNode: T; inline;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure TemporaryCurrentNode(Node: T; Proc: TProcedure); inline;
    property CurrentNode: T read GetCurrentNode;
  end;
  ///	<summary>
  ///	  This class, which decends from <see cref="TgSerializer" />, is used to
  ///	  serialize the published properties of a <see cref="TgBase" /> into XML
  ///	  format
  ///	</summary>
  TgSerializerXML = class(TgSerializerStackBase<IXMLNode>)
  public
    type
      TProcedure = reference to procedure;
      THelper<gBase: TgBase> = class(TgSerializationHelper<gBase,TgSerializerXML>)
      type
        E = Class(Exception)
        End;
      public
        class procedure Deserialize(AObject: gBase; ASerializer: TgSerializerXML; ARTTIProperty: TRTTIProperty = Nil); override;
        class procedure Serialize(AObject: gBase; ASerializer: TgSerializerXML; ARTTIProperty: TRTTIProperty = Nil); override;
      end;
      THelperBase = class(THelper<TgBase>);

      { TODO -oJim -cDefinations : Not sure how this relates to serialization }
      THelperIdentityObject = class(THelper<TgIdentityObject>)
      public
        class procedure Serialize(AObject: TgIdentityObject; ASerializer: TgSerializerXML; ARTTIProperty: TRTTIProperty = Nil); override;
      end;

      THelperList = class(THelper<TgList>)
      public
        class procedure Serialize(AObject: TgList; ASerializer: TgSerializerXML; ARTTIProperty: TRTTIProperty = Nil); override;
        class procedure DeserializeUnpublishedProperty(AObject: TgList; ASerializer: TgSerializerXML; const PropertyName: String); override;
      end;

      THelperIdentityList = class(THelper<TgIdentityList>)
      public
        class procedure Serialize(AObject: TgIdentityList; ASerializer: TgSerializerXML; ARTTIProperty: TRTTIProperty = Nil); override;
        class procedure DeserializeUnpublishedProperty(AObject: TgIdentityList; ASerializer: TgSerializerXML; const PropertyName: String); override;
        class procedure Deserialize(AObject: TgIdentityList; ASerializer: TgSerializerXML; ARTTIProperty: TRTTIProperty = Nil); override;
      end;
      THelperDictionary= class(THelper<TgDictionary>)
      public
        class procedure Serialize(AObject: TgDictionary; ASerializer: TgSerializerXML; ARTTIProperty: TRTTIProperty = Nil); override;
        class procedure DeserializeUnpublishedProperty(AObject: TgDictionary; ASerializer: TgSerializerXML; const PropertyName: String); override;
      end;

  strict private
    FDocument: TXMLDocument;
    FDocumentInterface : IXMLDocument;
    procedure Load(const AString: String);
  public
    constructor Create; override;
    class procedure Register;
    procedure AddValueProperty(const AName: String; AValue: Variant); override;
    procedure Deserialize(AObject: TgBase; const AString: String); override;
    function Serialize(AObject: TgBase; ADefaultClass: TgBaseClass): String; override;
    procedure AddObjectProperty(ARTTIProperty: TRTTIProperty; AObject: TgBase); override;
    function ExtractClassName(const AString: string): string; override;
    property Document: TXMLDocument read FDocument;
  end;

  ///	<summary>
  ///	   This Decendatnt of <see cref="TgSerializer" /> uses the JSON format.  See 
  ///	  <see href="http://www.json.org">www.json.org</see> specifications
  ///	</summary>
  TgSerializerJSON = class(TgSerializerStackBase<TJSONObject>)
  public
    type
      THelper<gBase: TgBase> = class(TgSerializationHelper<gBase,TgSerializerJSON>)
      type
        E = Class(Exception)
        End;
      public
        class procedure Deserialize(AObject: gBase; ASerializer: TgSerializerJSON; ARTTIProperty: TRTTIProperty = Nil); override;
        class procedure Serialize(AObject: gBase; ASerializer: TgSerializerJSON; ARTTIProperty: TRTTIProperty = Nil); override;
      end;
      THelperBase = class(THelper<TgBase>);

      THelperList = class(THelper<TgList>)
      public
        class procedure Serialize(AObject: TgList; ASerializer: TgSerializerJSON; ARTTIProperty: TRTTIProperty = Nil); override;
        class procedure DeserializeUnpublishedProperty(AObject: TgList; ASerializer: TgSerializerJSON; const PropertyName: String); override;
      end;

      THelperIdentityObject = class(THelper<TgIdentityObject>)
      public
        class procedure Serialize(AObject: TgIdentityObject; ASerializer: TgSerializerJSON; ARTTIProperty: TRTTIProperty = Nil); override;
      end;

      THelperIdentityList = class(THelper<TgIdentityList>)
      public
        class procedure Serialize(AObject: TgIdentityList; ASerializer: TgSerializerJSON; ARTTIProperty: TRTTIProperty = Nil); override;
        class procedure DeserializeUnpublishedProperty(AObject: TgIdentityList; ASerializer: TgSerializerJSON; const PropertyName: String); override;
       end;

  strict private
    FJSONObject: TJSONObject;
    procedure Load(const AString: string);
  public
    class procedure Register;
    constructor Create; override;
    destructor Destroy; override;
    function Serialize(AObject: TgBase; ADefaultClass: TgBaseClass): String; override;
    procedure AddValueProperty(const AName: string; AValue: Variant); override;
    procedure AddObjectProperty(ARTTIProperty: TRTTIProperty; AObject: TgBase); override;
    procedure Deserialize(AObject: TgBase; const AString: string); override;
    function ExtractClassName(const AString: string): string; override;
    property JSONObject: TJSONObject read FJSONObject write FJSONObject;
  end;

  TgSerializerCSV = class;

  TgNodeCSV = class(TStringList)
  public
    type
      TForEach = reference to procedure(const ColumnName,Value: String; Node: TgNodeCSV);

  private
    FName: String;
    FOwner: TgSerializerCSV;
    FParentNode: TgNodeCSV;
  public
    constructor Create(Owner: TgSerializerCSV; const Name: String = ''; ParentNode: TgNodeCSV = nil);
    destructor Destroy; override;
    procedure ForEach(Anon: TForEach);
    function Add(const Name,Value: String): Integer; overload;
    procedure Add(Value: TgNodeCSV); overload;
    function AddChild(const Name: String): TgNodeCSV;
    function AddItem(Index: Integer): TgNodeCSV;
    procedure ToRow(Columns: TStrings);
    property Name: String read FName write FName;
    property ParentNode: TgNodeCSV read FParentNode write FParentNode;
    property Owner: TgSerializerCSV read FOwner write FOwner;
  end;

  ///	<summary>
  ///	  This class, which decends from <see cref="TgSerializer" />, is used to
  ///	  serialize the published properties of a <see cref="TgBase" /> into a comma delimited text file.
  ///   All Classes will be assumed unless prefixed by a _className Column.  So when a export occurs if the class is different than the original it will output the _className column
  ///	</summary>
  TgSerializerCSV = class(TgSerializerStackBase<TgNodeCSV>)
  public
    type
      TProcedure = reference to procedure;
      THelper<gBase: TgBase> = class(TgSerializationHelper<gBase,TgSerializerCSV>)
      type
        E = Class(Exception)
        End;
      public
        class procedure Deserialize(AObject: gBase; ASerializer: TgSerializerCSV; ARTTIProperty: TRTTIProperty = Nil); override;
        class procedure Serialize(AObject: gBase; ASerializer: TgSerializerCSV; ARTTIProperty: TRTTIProperty = Nil); override;
      end;
      THelperBase = class(THelper<TgBase>);

      { TODO -oJim -cDefinations : Not sure how this relates to serialization }
      THelperIdentityObject = class(THelper<TgIdentityObject>)
      public
        class procedure Serialize(AObject: TgIdentityObject; ASerializer: TgSerializerCSV; ARTTIProperty: TRTTIProperty = Nil); override;
      end;

      THelperList = class(THelper<TgList>)
      public
        class procedure Serialize(AObject: TgList; ASerializer: TgSerializerCSV; ARTTIProperty: TRTTIProperty = Nil); override;
        class procedure Deserialize(AObject: TgList; ASerializer: TgSerializerCSV; ARTTIProperty: TRTTIProperty = Nil); override;
        class procedure DeserializeUnpublishedProperty(AObject: TgList; ASerializer: TgSerializerCSV; const PropertyName: String); override;
      end;

      THelperIdentityList = class(THelper<TgIdentityList>)
      public
        class procedure Serialize(AObject: TgIdentityList; ASerializer: TgSerializerCSV; ARTTIProperty: TRTTIProperty = Nil); override;
      end;

  strict private
    FHeadings: TStringList;
    FObjectNames: TStringList;
    FCurrentRow: TStringList;
    FAppendPath: TStack<String>;
    FDocument: TStringList;
    FBaseClass: TStack<TgBaseClass>;
    procedure Load(const AString: String);
    function GetAppendName: String;
    const _classname = '_classname';
  public
    constructor Create; override;
    destructor Destroy; override;
    class procedure Register;
    procedure AddObjectName(const Name: String);
    function GetCurrentColumnIndex(const AName: String; AutoAdd: Boolean = True): Integer;
    procedure AddValueProperty(const AName: String; AValue: Variant); override;
    procedure ForEachRow(Anon: TProcedure);
    procedure Deserialize(AObject: TgBase; const AString: String); override;
    function Serialize(AObject: TgBase; ADefaultClass: TgBaseClass = nil): String; override;
    procedure AddObjectProperty(ARTTIProperty: TRTTIProperty; AObject: TgBase); override;
    function ExtractClassName(const AString: string): string; override;
    function GetColumnValue(const AName: String; out Value: Variant): Boolean; overload;
    function GetColumnValue(const AName: String; out Value: Integer): Boolean; overload;
    function GetColumnValue(const AName: String; out Value: String): Boolean; overload;
    procedure AppendPath(const Name: String; Proc: TProcedure);
    property Headings: TStringList read FHeadings;
    property CurrentRow: TStringList read FCurrentRow;
    property AppendName: String read GetAppendName;
  end;

  [NotVisible]
  TgController = class(TgBase)
  end;

  TgModel = class(TgBase)
  strict private
    function GetController: TgController;
  private
    FVariables: TgDictionary;
  public
    function IsAuthorized(var AToken: String): Boolean; virtual;
    function PersistenceSegmentationString: String; virtual;
    class procedure Register;
  published
    property Controller: TgController read GetController;
    [NotVisible]
    property Variables: TgDictionary read FVariables;
  end;

  TgModelClass = class of TgModel;

  CascadeDelete = class(TCustomAttribute)
  end;

  DenyDelete = class(TCustomAttribute)
  end;

  TgWithQueryProcedure = reference to procedure(AQuery: TObject);

  TgConnection = class(TObject)
  strict private
    FConnectionDescriptor: TgConnectionDescriptor;
    FLinkEstablished: TDateTime;
    FLastUsed: TDateTime;
    FReferenceCount: Integer;
    FThreadID: Cardinal;
    function GetExpired: Boolean;
  public
    Connection: TObject;
    Transaction: TObject;
    constructor Create;
    destructor Destroy; override;
    procedure DecReferenceCount;
    procedure EnsureActive;
    procedure IncReferenceCount;
    function InUse: Boolean;
    property ConnectionDescriptor: TgConnectionDescriptor read FConnectionDescriptor write FConnectionDescriptor;
    property LinkEstablished: TDateTime read FLinkEstablished write FLinkEstablished;
    property LastUsed: TDateTime read FLastUsed write FLastUsed;
    property Expired: Boolean read GetExpired;
    property ThreadID: Cardinal read FThreadID write FThreadID;
  end;

  TgConnectionDescriptor = class(TgBase)

    type
      E = class(Exception)
      end;

  strict private
    FActiveConnectionList: TDictionary<Cardinal, TgConnection>;
    FCriticalSection: TCriticalSection;
    FInactiveConnectionList: TQueue<TgConnection>;
    FName: String;
    FParams: TStringList;
    FTTL: Integer;
    function GetParams: TStringList;
    function GetParamString: String;
    function GetServer: TgServer;
    function ReuseActiveConnection(AThreadID: Cardinal): TgConnection;
    function ReuseInactiveConnection(AThreadID: Cardinal): TgConnection;
    procedure SetParamString(const AValue: String);
    property Server: TgServer read GetServer;
  strict protected
    procedure CreateConnection(AConnection: TgConnection); virtual; abstract;
  public
    constructor Create(AOwner: TgBase = nil); override;
    destructor Destroy; override;
    function ActiveConnectionCount: Integer;
    function EnsureActive(AConnection: TgConnection): Boolean; virtual; abstract;
    procedure FreeConnection(AConnection: TObject); virtual; abstract;
    function GetConnection: TgConnection;
    function GetNewConnection(AThreadID: Cardinal): TgConnection;
    function InactiveConnectionCount: Integer;
    procedure ReleaseConnection;
    procedure FreeInactive;
    procedure Report(AStringList: TStringList);
    property Params: TStringList read GetParams;
  published
    property Name: String read FName write FName;
    property ParamString: String read GetParamString write SetParamString;
    property TTL: Integer read FTTL write FTTL;
  end;

  TgConnectionDescriptorDBX = class(TgConnectionDescriptor)
  strict protected
    procedure CreateConnection(AConnection: TgConnection); override;
    class function DriverName: String; virtual; abstract;
    class function GetDriverFunc: String; virtual; abstract;
    class function LibraryName: String; virtual; abstract;
    class function VendorLib: String; virtual; abstract;
  public
    function EnsureActive(AConnection: TgConnection): Boolean; override;
    procedure FreeConnection(AConnection: TObject); override;
  end;

  TgConnectionDescriptorDBXFirebird = class(TgConnectionDescriptorDBX)
  strict protected
    class function GetDriverFunc: string; override;
    class function LibraryName: string; override;
    class function VendorLib: string; override;
    class function DriverName: string; override;
  end;

  TgServer = class(TgBase)

    type
      E = class(Exception)
      end;

  strict private
    FHost: String;
    FPort: Integer;
    FMaxConnections: Integer;
    FConnectionDescriptors: TgList<TgConnectionDescriptor>;
    FTimeout: Integer;
    FMaxConnectionSemaphore: Cardinal;
    FName: String;
    function GetMaxConnectionSemaphore: Cardinal;
    function GetMaxConnections: Integer;
  public
    destructor Destroy; override;
    function ConnectionCount: Integer;
    procedure RemoveInactiveConnection;
    function Report: String;
    property MaxConnectionSemaphore: Cardinal read GetMaxConnectionSemaphore;
  published
    property Name: String read FName write FName;
    property Host: String read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property MaxConnections: Integer read GetMaxConnections write FMaxConnections;
    property ConnectionDescriptors: TgList<TgConnectionDescriptor> read FConnectionDescriptors;
    property Timeout: Integer read FTimeout write FTimeout;
  end;

  TgPersistenceManagerSQL = class(TgPersistenceManager)
  strict private
    FConnectionDescriptor: TgConnectionDescriptor;
    FConnectionDescriptorName: String;
    FObjectRelationalMap: TDictionary<String, String>;
  strict protected
    class function ConformIdentifier(const AName: String): String; virtual;
    function DeleteStatement: String;
    procedure ExecuteStatement(const AStatement: String; ABase: TgBase); virtual; abstract;
    function GetIdentity: Variant; virtual; abstract;
    function InsertStatement: String;
    function LoadStatement: String;
    function TableName: String; virtual;
    function UpdateStatement(AObject: TgIdentityObject): String;
    property ConnectionDescriptor: TgConnectionDescriptor read FConnectionDescriptor;
    property ObjectRelationalMap: TDictionary<String, String> read FObjectRelationalMap;
  public
    constructor Create(AOwner: TgBase = nil); override;
    destructor Destroy; override;
    procedure DeleteObject(AObject: TgIdentityObject); override;
    procedure Initialize; override;
    procedure SaveObject(AObject: TgIdentityObject); override;
  published
    property ConnectionDescriptorName: String read FConnectionDescriptorName write FConnectionDescriptorName;
  end;

  TgPersistenceManagerDBX = class(TgPersistenceManagerSQL)
  strict private
    procedure WithQuery(AWithQueryProcedure: TgWithQueryProcedure);
  strict protected
    procedure AssignQueryParams(AParams: TParams; ABase: TgBase);
    function DriverName: String; virtual; abstract;
    procedure ExecuteStatement(const AStatement: String; ABase: TgBase); override;
  public
    procedure ActivateList(AIdentityList: TgIdentityList); override;
    procedure Commit(AObject: TgIdentityObject); override;
    function Count(AIdentityList: TgIdentityList): Integer; override;
    procedure LoadObject(AObject: TgIdentityObject); override;
    procedure RollBack(AObject: TgIdentityObject); override;
    procedure StartTransaction(AObject: TgIdentityObject;ATransactionIsolationLevel: TgTransactionIsolationLevel = ilReadCommitted); override;
  end;

  TgPersistenceManagerDBXFirebird = class(TgPersistenceManagerDBX)
  strict protected
    function DriverName: string; override;
  public
    procedure Configure; override;
  end;

  PersistenceManagerClassName = class(TCustomAttribute)
  strict private
    FValue: String;
  public
    constructor Create(const AName: String);
    property Value: String read FValue;
  end;
  [MaxTextLength(50)]
  TString50 = record
  strict private
    FValue: String;
  public
    function GetValue: String;
    procedure SetValue(const AValue: String);
    class operator implicit(AValue: Variant): TString50; overload;
    class operator Implicit(AValue: TString50): Variant; overload;
    class operator Implicit(AValue: TString50): String; overload;
    property Value: String read GetValue write SetValue;
  end;
  ImpliedExpressionEvaulator = class(TCustomAttribute);

  TgDocument = class;

  TgElement = class(TgBase)
  public
    type
      E = class(Exception);
      TClassOf = class of TgElement;
      TProcessText = reference to procedure(const Text: String);
      [NotVisible]
      [ImpliedExpressionEvaulator]
      TObjectRef = record
        Base: TgBase;
        Name: String;
        class function New(const AName: String; AgBase: TgBase): TObjectRef; static;
        class function NewValue(const AName: String; AgBase: TgBase): TValue; static;
      end;

  { TODO : Handle Conditions }
  { TODO : ConditionSelf says don't do the outer tag, but do the inner tags }
  private
    FTagName: String;
    FNodeAttributes: TStringList;
    FgBase: TgBase;
    FPath: String;
    FCondition: Boolean;
    FConditionSelf: Boolean;
    FObject: TObjectRef;
    function GetgBase: TgBase;
    function GetModel: TgBase;
    class var _Tags: TDictionary<String, TClassOf>;
    function GetgDocument: TgDocument; overload;
  protected
    procedure SetObject(const Value: TObjectRef); virtual;
    function ExpandPath(const AName: String; const APrefix: String = ''): String; virtual;
  public
    class constructor Create;
    class destructor Destroy;
    class function CreateFromTag(Owner: TgElement; Node: IXMLNode; AgBase: TgBase): TgElement;
    function GetPropertyByName(const Name: String): TRTTIProperty;
    class procedure Register(const TagName: String; AClass: TClassOf);
    constructor Create(Owner: TgBase = nil); override;
    procedure ProcessChildNodes(SourceChildNodes, TargetChildNodes: IXMLNodeList); virtual;
    function CopyNode(Source: IXMLNode):IXMLNode;
    procedure ProcessNode(Source:IXMLNode; TargetChildNodes: IXMLNodeList); virtual;
    function GetValue(const Value: String): Variant;
    function ProcessValue(const Value: OleVariant): OleVariant; virtual;
    procedure ProcessText(SourceNode: IXMLNode; TargetChildNodes: IXMLNodeList); overload;
    procedure ProcessText(const Source: String; ProcessText: TProcessTExt; ProcessHTML: TProcessText); overload;
    function GetgDocument(out Value: TgDocument): Boolean; overload; virtual;
    function Skip: Boolean; virtual;
    destructor Destroy; override;
    property TagName: String read FTagName write FTagName;
    property gBase: TgBase read GetgBase write FgBase;
    property gDocument: TgDocument read GetgDocument;
    property NodeAttributes: TStringList read FNodeAttributes;
  published
    [NotVisible]
    [ImpliedExpressionEvaulator]
    property Condition: Boolean read FCondition write FCondition default True;
    [NotVisible]
    [ImpliedExpressionEvaulator]
    property ConditionSelf: Boolean read FConditionSelf write FConditionSelf default True;
    property Object_: TObjectRef read FObject write SetObject;
  end;

  TgDocument = class(TgElement)
  private
    FIsMobile: Boolean;
    FIsSecure: Boolean;
    FSearchPath: String;
    FAliasPath: String;
    FTargetDocument: TXMLDocument;
    FTargetDocumentInterface: IXMLDocument;
    FActive: Boolean;
    procedure SetActive(const Value: Boolean);
  public
    constructor Create(Owner: TgBase = nil); override;
    destructor Destroy; override;
    class function _ProcessText(const Source: String; AgBase: TgBase = nil): String; overload;
    class function _ProcessText(const Source: String; var Target: String; AgBase: TgBase = nil): Boolean; overload;
    function ProcessFile(const AFileName: String; ASearchPath: String; TargetChildNodes: IXMLNodeList; AgBase: TgBase = nil): Boolean; overload;
    function ProcessFile(const FileName: String; TargetChildNodes: IXMLNodeList; AgBase: TgBase = nil): Boolean; overload;
    function ProcessFile(const AFileName: String; AStream: TStream): Boolean; overload;
    function ProcessText(const Source: String; var Target: String; AgBase: TgBase = nil): Boolean; overload;
    function ProcessText(const Source: String; TargetChildNodes: IXMLNodeList; AgBase: TgBase = nil): Boolean; overload;
    function ProcessDocument(SourceDocument: IXMLDocument; TargetChildNodes: IXMLNodeList; AgBase: TgBase = nil): Boolean;
    function GetgDocument(out Value: TgDocument): Boolean; override;
    procedure Clear;
    property Target: TXMLDocument read FTargetDocument;
    property Active: Boolean read FActive write SetActive;
  published
    property SearchPath: String read FSearchPath write FSearchPath;
    property AliasPath: String read FAliasPath write FAliasPath;
    property IsSecure: Boolean read FIsSecure write FIsSecure;
    property IsMobile: Boolean read FIsMobile write FIsMobile;
  end;

  TgElementHTML = class(TgElement)
  public
    constructor Create(Owner: TgBase = nil); override;
  end;

  TgElementList = class(TgElement)
  private
    FObject: TgList;
  public
    procedure ProcessChildNodes(SourceChildNodes, TargetChildNodes: IXMLNodeList); override;
    procedure ProcessNode(Source: IXMLNode; TargetChildNodes: IXMLNodeList); override;
  published
    [ImpliedExpressionEvaulator]
    property Object_: TgList read FObject write FObject;
  end;

  TgElementAssign = class(TgElement)
  private
    FName: String;
    FValue: Variant;
  public
    procedure ProcessNode(Source: IXMLNode; TargetChildNodes: IXMLNodeList); override;
  published
    property Name: String read FName write FName;
    property Value: Variant read FValue write FValue;
  end;

  TgElementIf = class(TgElement)
  public
    const _then = 'then';
    const _else = 'else';
  public
    function Skip: Boolean; override;
    procedure ProcessNode(Source: IXMLNode; TargetChildNodes: IXMLNodeList); override;
  end;

  TgElementWith = class(TgElement)
  private
    FObject: TgBase;
  public
    procedure ProcessNode(Source: IXMLNode; TargetChildNodes: IXMLNodeList); override;
  published
    [ImpliedExpressionEvaulator]
    property Object_: TgBase read FObject write FObject;
  end;

  TgElementInclude = class(TgElement)
  private
    FFileName: String;
    FSearchPath: String;
  public
    procedure ProcessNode(Source: IXMLNode; TargetChildNodes: IXMLNodeList); override;
  published
    property FileName: String read FFileName write FFileName;
    property SearchPath: String read FSearchPath write FSearchPath;
  end;

  TgElementSelect = class(TgElement)
  private
    FName: String;
    FID: String;
  published
    property Name: String read FName write FName;
    property ID: String read FID write FID;
  end;

  TgPersistenceManagerIBX = class(TgPersistenceManagerSQL)
  strict private
    function GeneratorName: String;
    procedure WithQuery(AWithQueryProcedure: TgWithQueryProcedure);
  strict protected
    procedure AssignQueryParams(AParams: TParams; ABase: TgBase);
    procedure ExecuteStatement(const AStatement: String; ABase: TgBase); override;
    function GetIdentity: Variant; override;
    class function ConformIdentifier(const AName: string): string; override;
  public
    procedure ActivateList(AIdentityList: TgIdentityList); override;
    procedure Commit(AObject: TgIdentityObject); override;
    procedure Configure; override;
    function Count(AIdentityList: TgIdentityList): Integer; override;
    procedure LoadObject(AObject: TgIdentityObject); override;
    procedure RollBack(AObject: TgIdentityObject); override;
    procedure StartTransaction(AObject: TgIdentityObject;ATransactionIsolationLevel: TgTransactionIsolationLevel = ilReadCommitted); override;
  end;

  TgConnectionDescriptorIBX = class(TgConnectionDescriptor)
  strict private
    FDatabaseName: String;
    FPassword: String;
    FUserName: String;
  strict protected
    procedure CreateConnection(AConnection: TgConnection); override;
  public
    function EnsureActive(AConnection: TgConnection): Boolean; override;
    procedure FreeConnection(AConnection: TObject); override;
  published
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property Password: String read FPassword write FPassword;
    property UserName: String read FUserName write FUserName;
  end;

  Authorization = class(TgPropertyAttribute)
  end;

  TgMemo = record
  public
    FValue: array of String;
  private
    function GetCount: Integer;
    function GetItems(Index: Integer): String;
    procedure SetCount(const Value: Integer);
    procedure SetItems(Index: Integer; const Value: String);
  public
    function GetValue: String;
    procedure SetValue(const AValue: String);
    class operator Implicit(AValue: TgMemo): Variant; overload;
    class operator Implicit(AValue: Variant): TgMemo; overload;
    function IndexOf(const Value: String): Integer;
    function Add(const Value: String): Integer;
    property Value: String read GetValue write SetValue;
    property Count: Integer read GetCount write SetCount;
    property Items[Index: Integer]: String read GetItems write SetItems; default;
  end;

  TgWebCookie = record
  public
    type
      E = class(exception);
  strict private
    FExpire: TDateTime;
    FID: Integer;
    const Key: Cardinal = $FE23A322;
  public
    function GetValue: String;
    procedure SetValue(const AValue: String);
    property Expire: TDateTime read FExpire write FExpire;
    property ID: Integer read FID write FID;
    property Value: String read GEtValue write SetValue;
  end;

type
  TBuffer = Class(TObject)
  public
    Address : Pointer;
    Length : Integer;
  End;


procedure SplitPath(Const APath : String; Out AHead, ATail : String); overload;

procedure SplitPath(Const APath : String; Out AHead, ATail : String; const Delim: Char); overload;

procedure SplitPathLast(const APath: String; Out AHead, ATail : String);

Function FileToString(AFileName : String) : String;

Procedure StringToFile(const AString, AFileName : String);



// This method does nothing with the classes in the array.
// However, by referencing the classes in the array, the compiler
// will generate runtime type information for them.
// Register classes with this method that would otherwise be skipped
// by the compiler.
procedure RegisterRuntimeClasses(const AClasses: Array of TClass);

function EvalHTML(const AExpression: String; ABase: TgBase; out AIsHTML: Boolean): Variant;

function Eval(Const AExpression : String; ABase : TgBase): Variant;

function URLDecode(Const AString : String): String;

procedure SplitOnChar(const ASourceString: String; ASplitChar: Char; out AFirstPart, ASecondPart: String);

function TimeZoneBias: TDateTime;

function DayOfWeekStr(DateTime: TDateTime): string;

function MonthStr(DateTime: TDateTime): string;

procedure SplitBuffer(Const ASearchString : AnsiString; ABuffer : Pointer; ALength : Integer; AList : TList);

var
  ExecutablePath : String;

implementation

Uses
  System.Variants,
  XML.XMLDOM,
  Math,
  gExpressionEvaluator,
  System.StrUtils,
  Windows,
  Data.DBXCommon,
  ibDatabase,
  ibQuery
;

Const
{$IFDEF CPUX86}
  PROPSLOT_MASK    = $FF000000;
{$ENDIF CPUX86}
{$IFDEF CPUX64}
  PROPSLOT_MASK    = $FF00000000000000;
{$ENDIF CPUX64}

type
  TgBaseExpressionEvaluator = Class(TgExpressionEvaluator)
  Strict Protected
    FModel : TgBase;
    Function GetValue(Const AVariableName : String) : Variant; Override;
  Public
    Constructor Create(AModel : TgBase); Reintroduce; Virtual;
  End;

  TgHTMLExpressionEvaluator = class(TgBaseExpressionEvaluator)
  strict private
    FIsHTML: Boolean;
  Strict Protected
    Function GetValue(Const AVariableName : String) : Variant; Override;
  public
    property IsHTML: Boolean read FIsHTML;
  End;

function Eval(Const AExpression : String; ABase : TgBase): Variant;
Var
  ExpressionEvaluator : TgBaseExpressionEvaluator;
Begin
  ExpressionEvaluator := TgBaseExpressionEvaluator.Create(ABase);
  Try
    Result := ExpressionEvaluator.Evaluate(AExpression);
  Finally
    ExpressionEvaluator.Free;
  End;
End;

function EvalHTML(const AExpression: String; ABase: TgBase; out AIsHTML: Boolean): Variant;
Var
  ExpressionEvaluator : TgHTMLExpressionEvaluator;
Begin
  ExpressionEvaluator := TgHTMLExpressionEvaluator.Create(ABase);
  Try
    Result := ExpressionEvaluator.Evaluate(AExpression);
    AIsHTML := ExpressionEvaluator.IsHTML;
  Finally
    ExpressionEvaluator.Free;
  End;
End;

function IsField(P: Pointer): Boolean; inline;
begin
  Result := (IntPtr(P) and PROPSLOT_MASK) = PROPSLOT_MASK;
end;

procedure SplitPath(Const APath : String; Out AHead, ATail : String);
var
  BracketPosition: Integer;
  PeriodFirst: Boolean;
  PeriodPosition: Integer;
  Position: Integer;
Begin
  BracketPosition := Pos('[', APath);
  PeriodPosition := Pos('.', APath);

  if BracketPosition < 2 Then
    PeriodFirst := True
  else if PeriodPosition = 0 then
    PeriodFirst := False
  else
    PeriodFirst := PeriodPosition < BracketPosition;

  if PeriodFirst then
    Position := PeriodPosition
  else
    Position := BracketPosition;

  if Position > 0 then
  Begin
    AHead := Copy(APath, 1, Position - 1);
    if PeriodFirst then
      ATail := Copy(APath, Position + 1, MaxInt)
    else
      ATail := Copy(APath, Position, MaxInt);
  End
  Else
  Begin
    AHead := APath;
    ATail := '';
  End;
End;

procedure SplitPath(Const APath : String; Out AHead, ATail : String; const Delim: Char);
var
  BracketPosition: Integer;
  PeriodFirst: Boolean;
  PeriodPosition: Integer;
  Position: Integer;
Begin
  BracketPosition := Pos('[', APath);
  PeriodPosition := Pos(Delim, APath);

  if BracketPosition < 2 Then
    PeriodFirst := True
  else if PeriodPosition = 0 then
    PeriodFirst := False
  else
    PeriodFirst := PeriodPosition < BracketPosition;

  if PeriodFirst then
    Position := PeriodPosition
  else
    Position := BracketPosition;

  if Position > 0 then
  Begin
    AHead := Copy(APath, 1, Position - 1);
    if PeriodFirst then
      ATail := Copy(APath, Position + 1, MaxInt)
    else
      ATail := Copy(APath, Position, MaxInt);
  End
  Else
  Begin
    AHead := APath;
    ATail := '';
  End;
End;

procedure SplitPathLast(const APath: String; Out AHead, ATail : String);
var
  PeriodPosition: Integer;
begin
  PeriodPosition := Length(APath);
  while (PeriodPosition > 0) and (APath[PeriodPosition] <> '.') do
   Dec(PeriodPosition);
  if PeriodPosition = 0 then begin
    AHead := APath;
    ATail := '';
  end
  else begin
    AHead := Copy(APath,PeriodPosition+1,Length(APath)-PeriodPosition);
    ATail := Copy(APath,1,PeriodPosition-1);
  end;

end;

Function FileToString(AFileName : String) : String;
Var
  StringStream : TStringStream;
Begin
  StringStream := TStringStream.Create('');
  try
    StringStream.LoadFromFile(AFileName);
    Result := StringStream.DataString;
  finally
    StringStream.Free;
  end;
End;

Procedure StringToFile(const AString, AFileName : String);
Var
  StringStream : TStringStream;
Begin
  StringStream := TStringStream.Create(AString);
  try
    StringStream.SaveToFile(AFileName);
  finally
    StringStream.Free;
  end;
End;


function CreateAndDeserializeFromFile(ASerializerClass: TgSerializerClass; const AFileName: String): TgBase;
var
  Serializer: TgSerializer;
begin
  Serializer := ASerializerClass.Create;
  try
    Result := Serializer.CreateAndDeserialize(FileToString(AFileName));
  finally
    Serializer.Free;
  end;
end;

procedure RegisterRuntimeClasses(const AClasses: Array of TClass);
begin

end;

function URLDecode(Const AString : String): String;
var
  PSource : PChar;
  PDestination : PChar;
  TempString : String;
begin
  SetLength(TempString, Length(AString));
  PSource := PChar(AString);
  PDestination := PChar(TempString);
  while PSource^ <> #0 do
  begin
    If PSource^ = '+' Then
      PDestination^ := ' '
    Else If PSource^ <> '%' Then
      PDestination^ := PSource^
    Else
    Begin
      PDestination^ := Chr(StrToInt('$' + (PSource + 1)^ + (PSource + 2)^));
      Inc(PSource, 2);
    End;
    Inc(PSource);
    Inc(PDestination);
  end;
  SetLength(TempString, PDestination - PChar(TempString));
  Result := TempString;
end;

procedure SplitOnChar(const ASourceString: String; ASplitChar: Char; out AFirstPart, ASecondPart: String);
var
  SplitPos: Integer;
begin
  SplitPos := Pos( ASplitChar, ASourceString );
  If SplitPos > 0 Then
  Begin
    AFirstPart := Copy( ASourceString, 1, SplitPos - 1 );
    ASecondPart := Copy( ASourceString, SplitPos + 1, MaxInt );
  End
  Else
  Begin
    AFirstPart := ASourceString;
    ASecondPart := '';
  End;
end;

function TimeZoneBias: TDateTime;
var
  ATimeZone: TTimeZoneInformation;
begin
  Result := 0;
  case GetTimeZoneInformation(ATimeZone) of
    TIME_ZONE_ID_DAYLIGHT:
      Result := ATimeZone.Bias + ATimeZone.DaylightBias;
    TIME_ZONE_ID_STANDARD:
      Result := ATimeZone.Bias + ATimeZone.StandardBias;
    TIME_ZONE_ID_UNKNOWN:
      Result := ATimeZone.Bias;
  end;
  Result := Result / 1440;
end;

function DayOfWeekStr(DateTime: TDateTime): string;
begin
  Result := DaysOfWeek[DayOfWeek(DateTime)];
end;

function MonthStr(DateTime: TDateTime): string;
var
  Year, Month, Day: Word;
begin
  DecodeDate(DateTime, Year, Month, Day);
  Result := Months[Month];
end;

{ TODO : Unicodification }
procedure SplitBuffer(Const ASearchString : AnsiString; ABuffer : Pointer; ALength : Integer; AList : TList);
var
  SearchBuffer : PByteArray;
  SearchBufferLength : Integer;
  BufferArray : PByteArray;
  BufferIndex : Integer;
  SearchBufferIndex : Integer;
  Part : PByteArray;
  PartBuffer : TBuffer;
Begin
  BufferArray := ABuffer;
  Part := ABuffer;
  SearchBuffer := PByteArray(PChar(ASearchString));
  SearchBufferLength := Length(ASearchString);
  BufferIndex := 0;
  SearchBufferIndex := 0;
  While BufferIndex < ALength - SearchBufferLength Do
  Begin
     If BufferArray^[BufferIndex] = SearchBuffer^[SearchBufferIndex] Then
     Begin
       Repeat
         Inc(BufferIndex);
         Inc(SearchBufferIndex);
       Until (SearchBufferIndex = SearchBufferLength) Or (BufferArray^[BufferIndex] <> SearchBuffer[SearchBufferIndex]);
       If SearchBufferIndex = SearchBufferLength Then
       Begin
         PartBuffer := TBuffer.Create;
         PartBuffer.Address := Part;
         PartBuffer.Length := (BufferIndex - Integer(Cardinal(Part) - Cardinal(BufferArray)) - SearchBufferLength);
         AList.Add(PartBuffer);
         Part := @Part^[PartBuffer.Length + SearchBufferLength];
       End;
       SearchBufferIndex := 0;
     End
     Else
       Inc(BufferIndex);
  End;
  PartBuffer := TBuffer.Create;
  PartBuffer.Address := Part;
  PartBuffer.Length := ALength - BufferIndex;
  AList.Add(PartBuffer);
End;

{ TgBase }

function TgBase.OwnerByClass(AClass: TgBaseClass): TgBase;
begin
  if Assigned(Owner) then
  Begin
    if Owner.ClassType = AClass then
      Result := Owner
    Else
      Result := Owner.OwnerByClass(AClass);
  End
  Else
    Result := Nil;
end;

constructor TgBase.Create(AOwner: TgBase = Nil);
begin
  inherited Create;
  FOwner := AOwner;
  AutoCreate;
end;

class function TgBase.AddAttributes(ARTTIProperty: TRttiProperty): TArray<TCustomAttribute>;
begin

end;

class function TgBase.ApplicationPath: String;
begin
  Result := G.ApplicationPath(Self);
end;

class function TgBase.DataPath: String;
begin
  Result := IncludeTrailingPathDelimiter(ApplicationPath + 'Data');
end;

function TgBase.AsPointer: Pointer;
begin
  Result := Self;
end;

procedure TgBase.Assign(ASource : TgBase);
Var
  SourceObject : TgBase;
  DestinationObject : TgBase;
  RTTIProperty : TRTTIProperty;
Begin
  If ASource.ClassType = ClassType Then
  Begin
    For RTTIProperty In G.AssignableProperties(Self) Do
    Begin
      If RTTIProperty.PropertyType.IsInstance Then
      Begin
        SourceObject := TgBase(ASource.Inspect(RTTIProperty));
        If Assigned(SourceObject) And SourceObject.InheritsFrom(TgBase) Then
        Begin
          DestinationObject := TgBase(RTTIProperty.GetValue(Self).AsObject);
          if Assigned(DestinationObject) And Self.Owns(DestinationObject) then
          Begin
            If DestinationObject.InheritsFrom(TgBase) Then
              DestinationObject.Assign(SourceObject);
          End
          Else if RTTIProperty.IsWritable then
            RTTIProperty.SetValue(Self, RTTIProperty.GetValue(ASource));
        End;
      End
      Else
        RTTIProperty.SetValue(Self, RTTIProperty.GetValue(ASource));
    End;
  End
  Else
    Raise EgAssign.CreateFmt('Assignment mismatch between source ''%s'' and destination ''%s'' classes.', [ASource.ClassName, ClassName]);
End;

procedure TgBase.AutoCreate;
var
  RTTIProperty: TRTTIProperty;
  ObjectProperty : TgBase;
  ObjectPropertyClass: TgBaseClass;
  Value : TValue;
  Field : Pointer;
begin
  for RTTIProperty in G.AutoCreateProperties(Self) do
  Begin
    ObjectPropertyClass := TgBaseClass(RTTIProperty.PropertyType.AsInstance.MetaclassType);
    // See if there is a owner that can populate this property
    ObjectProperty := OwnerByClass(ObjectPropertyClass);
    if Not Assigned(ObjectProperty) then
    begin
      IsAutoCreating := True;
      ObjectProperty := ObjectPropertyClass.Create(Self);
      ObjectProperty.FOwnerProperty := RTTIProperty;
      IsAutoCreating := False;
    end;
    Value := ObjectProperty;
    Field := TRTTIInstanceProperty(RTTIProperty).PropInfo^.GetProc;
    Value.Cast(RTTIProperty.PropertyType.Handle).ExtractRawData(PByte(Self) + (IntPtr(Field) and (not PROPSLOT_MASK)));
  End;
end;

class function TgBase.Captionize(const AValue: String): String;
var
  Index: Integer;
  Len: Integer;
begin
  Result := AValue;
  // Remove lower case prefix
  while (Length(Result) > 0) and (Result[1] in ['a'..'z']) do
    Delete(Result,1,1);
  Len := Length(Result);
  for Index := Len-1 downto 1 do
    // replace _ with space
    if Result[Index] = '_' then
      Result[Index] := ' '
    // put space before capital letters that come after a lowercase letter
    else if (Result[Index] in ['a'..'z']) and (Result[Index+1] in ['A'..'Z']) then
      Insert(' ',Result,Index+1)
    else if (Result[Index] in ['a'..'z']) and (Result[Index+1] in ['0'..'9']) then
      Insert(' ',Result,Index+1)
    else if (Index < Len-2) and (Result[Index] in ['A'..'Z']) and (Result[Index+1] in ['A'..'Z']) and (Result[Index+2] in ['a'..'z']) then
      Insert(' ',Result,Index+1)
end;

procedure TgBase.Deserialize(ASerializerClass: TgSerializerClass; const AString: String);
var
  Serializer: TgSerializer;
begin
  if (AString = '') or (AString = #$D#$A) then exit;

  Serializer := ASerializerClass.Create;
  try
    Serializer.Deserialize(Self, AString);
  finally
    Serializer.Free;
  end;
end;

function TgBase.DoGetInValues(const APath, Name: String): Boolean;
var
  RTTIProperty: TRttiProperty;
  RttiEnumerationType: TRttiEnumerationType;
  Value: TValue;
  I: Integer;
  ISet: set of 0..31;
begin
  Result := False;
  if not DoGetProperties(APath,RTTIProperty) then exit;
  Value := RTTIProperty.GetValue(Self);
  if RTTIProperty.PropertyType.IsSet then begin
    RttiEnumerationType := TRTTISetType(RTTIProperty.PropertyType).ElementType as TRTTIEnumerationType;
    I := GetEnumValue(RttiEnumerationType.Handle,Name);
    Integer(ISet) := GetOrdProp(Self,TRttiInstanceProperty(RTTIProperty).PropInfo);
    Result := (I >= 0) and (I in ISet);
  end
  else
    Result := GetEnumValue(RttiEnumerationType.Handle,Name) = Value.AsOrdinal;
end;

class function TgBase.DoGetMembers(const APath: String; out AValue: TRttiMember): boolean;
begin
  Result := DoGetProperties(APath,TRttiProperty(AValue)) or DoGetMethods(APath,TRttiMethod(AValue));
end;

class function TgBase.DoGetMethods(const APath: String; out AValue: TRttiMethod):
    Boolean;
begin
  AValue := G.MethodByName(Self,APath);
  Result := Assigned(AValue);
end;

function TgBase.DoGetValues(Const APath : String; Out AValue : Variant): Boolean;
Var
  Head : String;
  Tail : String;
Begin
  Result := False;
  SplitPath(APath, Head, Tail);
  Result := DoGetValues(G.PropertyByName(Self, Head),AValue,Tail);
End;

function TgBase.DoGetObjects(const APath: String; out AValue: TgBase): Boolean;
Var
  Head : String;
  RTTIProperty : TRttiProperty;
  Tail : String;
Begin
  Result := False;
  SplitPath(APath, Head, Tail);
  RTTIProperty := G.PropertyByName(Self, Head);
  if Assigned(RTTIProperty) then
  begin
    if Not RTTIProperty.IsReadable then
      raise EgValue.CreateFmt('%s.%s is not a readable property.', [ClassName, RTTIProperty.Name]);
    if RTTIProperty.PropertyType.IsInstance then
    begin
      AValue := TgBase(RTTIProperty.GetValue(Self).AsObject);
      if Tail > '' then
        Result := AValue.DoGetObjects(Tail, AValue)
      else
        Result := True;
    end
    Else
      raise EgValue.CreateFmt('Can''t return %s.%s, because %s is not an object property', [RTTIProperty.Name, Tail, RTTIProperty.Name]);
  end;
End;

class function TgBase.DoGetProperties(const APath: String; out ARTTIProperty:
    TRTTIProperty; AgBase: TgBase = nil): Boolean;
Var
  Head : String;
  ObjectProperty: TgBase;
  Tail : String;
Begin
  ARTTIProperty := G.PropertyByName(Self, APath);
  if Assigned(ARTTIProperty) then Exit(True);
  Result := False;
  SplitPath(APath, Head, Tail);
  ARTTIProperty := G.PropertyByName(Self, Head);
  if Assigned(ARTTIProperty) Then
  begin
    if ARTTIProperty.PropertyType.IsInstance then
    begin
      if Tail > '' then
      Begin
        ObjectProperty := TgBase(ARTTIProperty.GetValue(AgBase).AsObject);
        Result := ObjectProperty.DoGetProperties(Tail, ARTTIProperty,ObjectProperty);
      End
    end
    Else
      Result := True;
  end;
End;

function TgBase.DoGetValues(ARttiProperty: TRttiProperty; out AValue: Variant;
    const ATail: String = ''): Boolean;
var
  ObjectProperty: TgBase;
  ATValue: TValue;
  ClassProperty: TClass;
  PropertyValue: TValue;
  RecordProperty: G.TgRecordProperty;
  RTTIProperty : TRttiProperty;
begin
  Result := False;
  if not Assigned(ARTTIProperty) then exit;
  if Not ARTTIProperty.IsReadable then
    raise EgValue.CreateFmt('%s.%s is not a readable property.', [ClassName, ARTTIProperty.Name]);
  if ARTTIProperty.PropertyType.IsInstance then
  begin
    if ATail > '' then
    Begin
      ObjectProperty := TgBase(ARTTIProperty.GetValue(Self).AsObject);
      Result := ObjectProperty.DoGetValues(ATail, AValue);
    End
    Else
      Result := False;
//      raise EgValue.CreateFmt('Can''t return %s.%s, because it''s an object property', [ClassName, ARTTIProperty.Name]);
  end
  Else if ARTTIProperty.PropertyType.IsRecord Then
  Begin
    RecordProperty := G.RecordProperty(ARTTIProperty);
    If Not Assigned(RecordProperty.Getter) then
      Raise EgValue.CreateFmt('%s has no GetValue method for runtime assignment.', [ARTTIProperty.Name]);
    PropertyValue := ARTTIProperty.GetValue(Self);
    AValue := RecordProperty.Getter.Invoke(PropertyValue, []).AsVariant;
    Result := True;
  End
  Else if (ARTTIProperty.PropertyType is TRttiClassRefType) then
  begin
//      If Not Assigned(RecordProperty.Getter) then
//        Raise EgValue.CreateFmt('%s has no GetValue method for runtime assignment.', [ARTTIProperty.Name]);
    ClassProperty := ARTTIProperty.GetValue(Self).AsClass;
    if Assigned(ClassProperty) then
      AValue := ClassProperty.UnitName+'.'+ClassProperty.ClassName
    else
      AValue := '';
    Result := True;
  end
  else
  Begin
    if ATail = '' then
    Begin
      case ARTTIProperty.PropertyType.TypeKind of
        TkEnumeration
        : if (ARTTIProperty.PropertyType.Handle = TypeInfo(Boolean)) Then
          Begin
            AValue := ARTTIProperty.GetValue(Self).AsBoolean;
            Result := True;
          end
          else begin
            AValue := ARTTIProperty.GetValue(Self).ToString;
//              AValue := GetEnumName(ARTTIProperty.PropertyType.Handle,AValue);
            Result := True;
          end;
        tkUString
        : begin
            AValue := ARTTIProperty.GetValue(Self).ToString;
            Result := True;
          end;
        TkSet
        : begin
            AValue := ARTTIProperty.GetValue(Self).ToString;
            Result := True;
          end;
      Else
        Begin
          ATValue := ARTTIProperty.GetValue(Self);
          AValue := ATValue.AsType<Variant>;
          Result := True;
        End;
      end;

    End
    Else
      raise EgValue.CreateFmt('Can''t return %s.%s, because %s is not an object property', [ARTTIProperty.Name, ATail, ARTTIProperty.Name]);
  End
end;

function TgBase.DoSetValues(Const APath : String; AValue : Variant): Boolean;
Var
  Head: String;
  ObjectProperty: TgBase;
  BaseClassValue: TgBaseClass;
  PropertyValue: TValue;
  RecordProperty: G.TgRecordProperty;
  RTTIProperty : TRTTIProperty;
  RTTIMethod : TRTTIMethod;
  Tail: String;
  Value : TValue;
Begin
  Result := False;
  SplitPath(APath, Head, Tail);
  RTTIProperty := G.PropertyByName(Self, Head);
  if Assigned(RTTIProperty) then
  begin
    if RTTIProperty.PropertyType.IsInstance then
    begin
      if Tail > '' then
      Begin
        ObjectProperty := TgBase(RTTIProperty.GetValue(Self).AsObject);
        Result := ObjectProperty.DoSetValues(Tail, AValue);
      End
      Else
        raise EgValue.CreateFmt('Can''t set %s.%s, because it''s an object property', [ClassName, RTTIProperty.Name]);
    end
    Else if RTTIProperty.PropertyType.IsRecord then
    begin
      RecordProperty := G.RecordProperty(RTTIProperty);
      If Not Assigned(RecordProperty.Setter) then
        Raise EgValue.CreateFmt('%s has no SetValue method for runtime assignment.', [RTTIProperty.Name]);
      PropertyValue := RTTIProperty.GetValue(Self);
      RecordProperty.Setter.Invoke(PropertyValue, [TValue.From<Variant>(AValue)]);
      RTTIProperty.SetValue(Self, PropertyValue);
      Result := True;
    end
    Else
    Begin
      if Tail = '' then
      Begin
        if Not RTTIProperty.IsWritable then
          raise EgValue.CreateFmt('%s.%s is not settable.', [ClassName, RTTIProperty.Name]);
        Case RTTIProperty.PropertyType.TypeKind Of
          TkEnumeration :
            Value := TValue.FromVariant(VarAsType(AVAlue, VarBoolean));
          TkInteger :
            Value := TValue.FromVariant(VarAsType(AValue, VarInteger));
          TkFloat :
          Begin
            case (VarType(AValue) and varTypeMask) of
              varString, varUString:
              if SameText(RTTIProperty.PropertyType.Name, 'TDate') or SameText(RTTIProperty.PropertyType.Name, 'TDateTime') then
                Value := StrToDateTime(AValue)
              else
                Value := StrToFloat(AValue);
            Else
              Value := TValue.FromVariant(VarAsType(AValue, VarDouble));
            end;
          End;
          TkVariant :
            Value := TValue.FromVariant(AValue);
          TkUString :
            Value := TValue.FromVariant(VarAsType(AValue, VarUString));
          TkString :
            Value := TValue.FromVariant(VarAsType(AValue, VarString));
          TkClassRef :
            if AValue = '' then
              Value := TClass(nil)
            else begin
              BaseClassValue := G.ClassByName(AValue);
              Value := TClass(BaseClassValue);
//              if (RTTIProperty.PropertyType as TRttiClassRefType).
              if Value.IsEmpty then
                raise EgValue.CreateFmt('%s was not found in ClassByName for the %s.%s property', [String(AValue),ClassName, RTTIProperty.Name]);
            end
        Else
          Raise EgValue.CreateFmt('%s.%s is not a value property', [ClassName, RTTIProperty.Name]);
        End;
        RTTIProperty.SetValue(Self, Value);
        Result := True;
      End
      Else
        raise EgValue.CreateFmt('Can''t set %s.%s, because %s is not an object property', [RTTIProperty.Name, Tail, RTTIProperty.Name]);
    End
  end
  Else
  Begin
    RTTIMethod := G.MethodByName(Self, Head);
    if Assigned(RTTIMethod) then
    Begin
      RTTIMethod.Invoke(Self, []);
      Result := True;
    End;
  End;
End;

class function TgBase.FriendlyName: String;
Begin
  if SameText(UnitName, TgBase.UnitName) then
    Result := Copy(ClassName, 3, MaxInt)
  Else
    Result := Copy(ClassName, 2, MaxInt);
  Result := ReplaceText(ReplaceText(Result, '<', '_'), '>', '_')
End;

class function TgBase.GetAttribute<T>(ARttiNamedObject: TRttiNamedObject): T;
begin
  if not GetAttribute<T>(ARttiNamedObject,Result) then
    Result := Default(T);
end;

class function TgBase.GetAttribute<T>(ARttiNamedObject: TRttiNamedObject; out
    Attribute: T): boolean;
var
  CustomAttribute: TCustomAttribute;
  CustomAttributeClass: TCustomAttributeClass;
  ATypeInfo: pTypeInfo;
  ATypeData: PTypeData;
begin
  Result := False;
  if not Assigned(ARttiNamedObject) then exit;
  ATypeInfo := TypeInfo(T);
  if (ATypeInfo.Kind <> tkClass) then exit;

  ATypeData := GetTypeData(ATypeInfo);
  CustomAttributeClass  := Pointer(ATypeData.ClassType);
  for CustomAttribute in ARttiNamedObject.GetAttributes do
    if CustomAttribute is CustomAttributeClass then begin
      pPointer(@Attribute)^ := CustomAttribute;
      Exit(True);
    end;
  Result := (ARttiNamedObject is TRttiProperty) and  GetAttribute<T>((ARttiNamedObject as TRttiProperty).PropertyType,Attribute);
end;

class function TgBase.GetAttribute<T>(ARttiType: TRttiType): T;
begin
  if not GetAttribute<T>(ARttiType,Result) then
    Result := Default(T);
end;

class function TgBase.GetAttribute<T>(ARttiType: TRttiType; out Attribute: T):
    boolean;
var
  CustomAttribute: TCustomAttribute;
  CustomAttributeClass: TCustomAttributeClass;
  ATypeInfo: pTypeInfo;
  ATypeData: PTypeData;
begin
  ATypeInfo := TypeInfo(T);
  if (ATypeInfo.Kind <> tkClass) then exit;
  ATypeData := GetTypeData(ATypeInfo);
  CustomAttributeClass  := Pointer(ATypeData.ClassType);
  for CustomAttribute in ARttiType.GetAttributes do
    if CustomAttribute is CustomAttributeClass then begin
      pPointer(@Attribute)^ := CustomAttribute;
      Exit(True);
    end;
  Result := False;
end;

class function TgBase.GetAttributes<T>(ARttiNamedObject: TRttiNamedObject; var
    Attributes: TArray<T>): boolean;
var
  CustomAttribute: TCustomAttribute;
  CustomAttributeClass: TCustomAttributeClass;
  Item: T;
  ATypeInfo: pTypeInfo;
  ATypeData: PTypeData;
begin
  Result := False;
  if not Assigned(ARttiNamedObject) then exit;

  ATypeInfo := TypeInfo(T);
  if (ATypeInfo.Kind <> tkClass) then exit;
  ATypeData := GetTypeData(ATypeInfo);
  CustomAttributeClass  := Pointer(ATypeData.ClassType);
  for CustomAttribute in ARttiNamedObject.GetAttributes do
    if CustomAttribute is CustomAttributeClass then begin
      pPointer(@Item)^ := CustomAttribute;
      SetLength(Attributes,Length(Attributes)+1);
      Attributes[High(Attributes)] := Item;
    end;
  if (ARttiNamedObject is TRttiProperty) then
    GetAttributes<T>((ARttiNamedObject as TRttiProperty).PropertyType,Attributes);
  Result := Length(Attributes) > 0;
end;

class function TgBase.GetAttributes<T>(ARttiType: TRttiType; var Attributes:
    TArray<T>): boolean;
var
  CustomAttribute: TCustomAttribute;
  CustomAttributeClass: TCustomAttributeClass;
  Item: T;
  ATypeInfo: pTypeInfo;
  ATypeData: PTypeData;
begin
  ATypeInfo := TypeInfo(T);
  if (ATypeInfo.Kind <> tkClass) then exit;
  ATypeData := GetTypeData(ATypeInfo);
  CustomAttributeClass  := Pointer(ATypeData.ClassType);
  for CustomAttribute in ARttiType.GetAttributes do
    if CustomAttribute is CustomAttributeClass then begin
      pPointer(@Item)^ := CustomAttribute;
      SetLength(Attributes,Length(Attributes)+1);
      Attributes[High(Attributes)] := Item;
    end;
  Result := Length(Attributes) > 0;
end;

function TgBase.GetCaptions(const AName: String): String;
begin
  // TODO -cMM: TgBase.GetCaptions default body inserted
  Result := GetCaptions(GetProperties(AName));
  if Result = '' then
    Result := Captionize(AName);
end;

function TgBase.GetCaptions(const RTTIProperty: TRTTIProperty): String;
var
  Attributes: TArray<TCustomAttribute>;
begin
  // TODO -cMM: TgBase.GetCaptions default body inserted
  Attributes := nil;
  if Assigned(RTTIProperty) then
    Attributes := G.PropertyAttributes(G.TgPropertyAttributeClassKey.Create(RTTIProperty,Caption));
  if Assigned(Attributes) then
    Result := (Attributes[0] as Caption).Value
  else
    Result := '';
end;

function TgBase.GetEnumerator: TEnumerator;
begin
  Result.Init(Self);
end;

function TgBase.GetFriendlyClassName: String;
Begin
  Result := FriendlyName;
End;

function TgBase.GetHelps(const AName: String): String;
begin
  Result := GetHelps(GetProperties(AName));
end;

function TgBase.GetHelps(const RTTIProperty: TRTTIProperty): String;
var
  Attributes: TArray<TCustomAttribute>;
begin
  // TODO -cMM: TgBase.GetCaptions default body inserted
  Attributes := nil;
  if Assigned(RTTIProperty) then
    Attributes := G.PropertyAttributes(G.TgPropertyAttributeClassKey.Create(RTTIProperty,Help));
  if Assigned(Attributes) then
    Result := (Attributes[0] as Caption).Value
  else
    Result := '';
end;

function TgBase.GetPathCount: Integer;
begin
  Result := Length(RTTIValueProperties);
end;

function TgBase.GetPathIndexOf(const APath: String): Integer;
begin
  Result := PathCount-1;
  while (Result >= 0) and not SameText(Paths[Result],APath) do
    Dec(Result);
end;

function TgBase.GetPaths(AIndex: Integer): String;
begin
  Result := RTTIValueProperties[AIndex].Name;
end;

function TgBase.GetPathValues(AIndex: Integer): TPathValue;
begin
  Result.Path := GetPaths(AIndex);
  if not DoGetValues(Result.Path,Result.Value) then
    Result.Value := varError;
  if not DoGetProperties(Result.Path,Result.RTTIProperty) then
    Result.RTTIProperty := nil;
end;

function TgBase.GetModel: TgModel;
begin
  if InheritsFrom(TgModel) then
    Result := TgModel(Self)
  else if Assigned(Owner) then
    Result := Owner.Model
  else
    Result := Nil;
end;

function TgBase.GetObjectChildPathName(AChild: TgBase): String;
begin
  Result := '';
  if Assigned(Owner) then
    Result := Result+Owner.GetObjectChildPathName(Self);
end;

function TgBase.GetValues(Const APath : String): Variant;
Begin
  If Not DoGetValues(APath, Result) Then
    Raise EgValue.CreateFmt('Path ''%s'' not found. ClassName ''%s''', [APath,ClassName]);
End;

function TgBase.GetObjects(Const APath : String): TgBase;
Begin
  If Not DoGetObjects(APath, Result) Then
    Raise EgValue.CreateFmt('Path ''%s'' not found.', [APath]);
End;

function TgBase.GetProperties(Const APath : String): TRTTIProperty;
Begin
  If Not DoGetProperties(APath, Result,Self) Then
    Raise EgValue.CreateFmt('Path ''%s'' not found.', [APath]);
End;

function TgBase.GetStates(Index: TgBase.TState): Boolean;
begin
  Result := Index in FStates;
end;

function TgBase.Inspect(ARTTIProperty: TRttiProperty): TObject;
begin
  IsInspecting := True;
  Result := ARTTIProperty.GetValue(Self).AsObject;
  IsInspecting := False;
end;

function TgBase.OwnerProperty: TRTTIProperty;
var
  RTTIProperty: TRTTIProperty;
begin
  if Assigned(FOwnerProperty) then Exit(FOwnerProperty);
  Result := Nil;
  if Not Assigned(Owner) then
    Exit;
  for RTTIProperty in G.ObjectProperties(Owner) do
    if Owner.Inspect(RTTIProperty) = Self then
      Exit(RTTIProperty);
end;

function TgBase.Owns(ABase : TgBase): Boolean;
Begin
  Result := Assigned(ABase) And (ABase.Owner = Self);
End;

class function TgBase.RTTIValueProperties: TArray<TRTTIProperty>;
begin
  Result := G.AssignableProperties(Self);
end;

function TgBase.Serialize(ASerializerClass: TgSerializerClass; ADefaultClass: TgBaseClass): String;
var
  Serializer: TgSerializer;
begin
  Serializer := ASerializerClass.Create;
  try
    Result := Serializer.Serialize(Self,ADefaultClass);
  finally
    Serializer.Free;
  end;
end;

function TgBase.Serialize(ASerializerClass: TgSerializerClass): String;
begin
  Result := Serialize(ASerializerClass,TgBaseClass(Self.ClassType));
end;

procedure TgBase.SetStates(const AIndex: TgBase.TState; const AValue: Boolean);
begin
  if AValue then
    Include(FStates, AIndex)
  Else
    Exclude(FStates, AIndex);
end;

procedure TgBase.SetValues(Const APath : String; AValue : Variant);
Begin
  If Not DoSetValues(APath, AValue) Then
    Raise EgValue.CreateFmt('Path ''%s'' not found.', [APath]);
End;

function TgBase.UseRestPath(const Path: String; var TemplateName: String;
  out gBase: TgBase; const Delim: char): Boolean;
begin
  TemplateName := '';
  Result := DoUseRestPath(Path,TemplateName,gBase,Delim)
end;

function TgBase.DoUseRestPath(const Path: String; var TemplateName: String;
  out gBase: TgBase; const Delim: char = '/'): Boolean;
var
  Head, Tail: String;
begin
  if Path = '' then begin
    gBase := Self;
    Exit(True);
  end;
  SplitPath(Path,Head,Tail,Delim);
  Result := DoGetObjects(Head,gBase) and Assigned(gBase);
  if not Result then exit;
  if TemplateName <> '' then
    TemplateName := TemplateName + '-' + Head
  else
    TemplateName := Head;
  Result := (Tail = '') or gBase.DoUseRestPath(Tail,TemplateName,gBase,Delim);
end;

{ G }

class procedure G.Initialize;
const
  sServerPath = 'Servers.xml';
var
  BaseTypes: TList<TRTTIType>;
  RTTIType: TRTTIType;
  Comparer: TgBaseClassComparer;
  FileName: string;
  PersistenceManager : TgPersistenceManager;
  Servers: TgList<TgServer>;
  Server : TgServer;
  ConnectionDescriptor : TgConnectionDescriptor;
  ServerString: String;
begin
  for RTTIType in FRTTIContext.GetTypes do
  begin
    If RTTIType.IsInstance And RTTIType.AsInstance.MetaclassType.InheritsFrom(TgSerializationHelper) And Not (RTTIType.AsInstance.MetaclassType = TgSerializationHelper) Then
      InitializeSerializationHelpers(RTTIType);
  end;
  //Make sure the types are in ancestral order
  BaseTypes := TList<TRTTIType>.Create;
  try
    for RTTIType in FRTTIContext.GetTypes do
    if RTTIType.IsInstance And RTTIType.AsInstance.MetaclassType.InheritsFrom(TgBase) then
      BaseTypes.Add(RTTIType);
    Comparer := TgBaseClassComparer.Create;
    try
      BaseTypes.Sort(Comparer);
    finally
      Comparer.Free;
    end;
    //Process the persistence manager classes first
    for RTTIType in BaseTypes do
    if RTTIType.AsInstance.MetaclassType.InheritsFrom(TgPersistenceManager) then
    begin
      InitializeProperties(RTTIType);
      InitializeAttributes(RTTIType);
      InitializeObjectProperties(RTTIType);
      InitializePropertyByName(RTTIType);
      InitializeMethodByName(RTTIType);
      InitializeRecordProperty(RTTIType);
      InitializeAutoCreate(RTTIType);
      InitializeCompositeProperties(RTTIType);
      InitializeAssignableProperties(RTTIType);
      InitializeSerializableProperties(RTTIType);
    end;
    //Then initialize the structure caches
    for RTTIType in BaseTypes do
    if Not RTTIType.AsInstance.MetaclassType.InheritsFrom(TgPersistenceManager) then
    begin
      InitializeProperties(RTTIType);
      InitializeAttributes(RTTIType);
      InitializeObjectProperties(RTTIType);
      InitializePropertyByName(RTTIType);
      InitializeMethodByName(RTTIType);
      InitializeRecordProperty(RTTIType);
      InitializeDisplayPropertyNames(RTTIType);
      InitializePropertyValidationAttributes(RTTIType);
      InitializeAutoCreate(RTTIType);
      InitializeCompositeProperties(RTTIType);
      InitializeAssignableProperties(RTTIType);
      InitializeSerializableProperties(RTTIType);
      InitializeVisibleProperties(RTTIType);
      InitializePersistableProperties(RTTIType);
      InitializePersistenceManager(RTTIType);
    end;
  finally
    BaseTypes.Free;
  end;
  // Load saved servers (and their connection descriptors) into G structures.
  if FileExists(G.DataPath + sServerPath) then
  Begin
    Servers := TgList<TgServer>.Create;
    try
      ServerString := FileToString(G.DataPath + sServerPath);
      Servers.Deserialize(TgSerializerXML, ServerString);
      Servers.First;
      while Not Servers.EOL do
      begin
        Server := TgServer.Create;
        Server.Assign(Servers.Current);
        FServers.AddOrSetValue(Server.Name, Server);
        for ConnectionDescriptor in Server.ConnectionDescriptors do
          FConnectionDescriptors.AddOrSetValue(ConnectionDescriptor.Name, ConnectionDescriptor);
        Servers.Next;
      end;
    finally
      Servers.Free;
    end;
  End;
  ForceDirectories(G.PersistenceManagerPath);
  for PersistenceManager in G.PersistenceManagers do
  Begin
    FileName := PersistenceManager.FileName;
    ForceDirectories(ExtractFilePath(FileName));
    if Not FileExists(FileName) then
    Begin
      PersistenceManager.Configure;
      StringToFile(PersistenceManager.Serialize(TgSerializerXML), FileName);
    End;
    PersistenceManager.Initialize;
  End;
  ForceDirectories(G.DataPath);
  Servers := TgList<TgServer>.Create;
  try
    for Server in G.FServers.Values do
    begin
      Servers.ItemClass := TgBaseClass(Server.ClassType);
      Servers.Add;
      Servers.Current.Assign(Server);
    end;
    ServerString := Servers.Serialize(TgSerializerXML,TgList<TgServer>);
    StringToFile(ServerString, G.DataPath + sServerPath);
  finally
    Servers.Free;
  end;
  DoAfterInit;
end;

class procedure G.InitializeAttributes(ARTTIType: TRTTIType);
var
  Attribute: TCustomAttribute;
  Pair : TPair<TgBaseClass, TCustomAttributeClass>;
  Attributes : TArray<TCustomAttribute>;
  BaseClass: TgBaseClass;
  RTTIProperty: TRTTIProperty;
  ClassValidationAttributes : TArray<Validation>;
  PropertyAttributeClassKey : TgPropertyAttributeClassKey;

  procedure AddAttribute;
  begin
    Pair.Key := TgBaseClass(ARTTIType.AsInstance.MetaclassType);
    Pair.Value := TCustomAttributeClass(Attribute.ClassType);
    FAttributes.TryGetValue(Pair, Attributes);
    SetLength(Attributes, Length(Attributes) + 1);
    Attributes[Length(Attributes) - 1] := Attribute;
    FAttributes.AddOrSetValue(Pair, Attributes);

    if Assigned(RTTIProperty) then
    Begin
      PropertyAttributeClassKey.RTTIProperty := RTTIProperty;
      PropertyAttributeClassKey.AttributeClass := TCustomAttributeClass(Attribute.ClassType);
      FPropertyAttributes.TryGetValue(PropertyAttributeClassKey, Attributes);
      SetLength(Attributes, Length(Attributes) + 1);
      Attributes[Length(Attributes) - 1] := Attribute;
      FPropertyAttributes.AddOrSetValue(PropertyAttributeClassKey, Attributes);
    End;

    if Not Assigned (RTTIProperty) And Attribute.InheritsFrom(Validation) then
    Begin
      FClassValidationAttributes.TryGetValue(Pair.Key, ClassValidationAttributes);
      SetLength(ClassValidationAttributes, Length(Attributes) + 1);
      ClassValidationAttributes[Length(Attributes) - 1] := Validation(Attribute);
      FClassValidationAttributes.AddOrSetValue(Pair.Key, ClassValidationAttributes);
    End;

  end;

begin
  // Add Class Attributes
  RTTIProperty := Nil;
  for Attribute in ARTTIType.GetAttributes do
    AddAttribute;
  BaseClass := TgBaseClass(ARTTIType.AsInstance.MetaclassType);
  // Add Property Attributes
  for RTTIProperty in Properties(BaseClass) do
  if RTTIProperty.Visibility = mvPublished then
  begin
    for Attribute in RTTIProperty.GetAttributes do
    begin
      if Attribute.InheritsFrom(TgPropertyAttribute) then
        TgPropertyAttribute(Attribute).RTTIProperty := RTTIProperty;
      AddAttribute;
    end;
    for Attribute in BaseClass.AddAttributes(RTTIProperty) do
    begin
      FOwnedAttributes.Add(Attribute);
      if Attribute.InheritsFrom(TgPropertyAttribute) then
        TgPropertyAttribute(Attribute).RTTIProperty := RTTIProperty;
      AddAttribute;
    end;
    for Attribute in RTTIProperty.PropertyType.GetAttributes do
      AddAttribute;
      
  end;
end;

class procedure G.InitializeObjectProperties(ARTTIType: TRTTIType);
Var
  BaseClass: TgBaseClass;
  PropertyClass: TgIdentityObjectClass;
  RTTIProperty : TRTTIProperty;
  RTTIProperties: TArray<TRTTIProperty>;
  IdentityObjectClassProperties : TArray<TgIdentityObjectClassProperty>;

Begin
  BaseClass := TgBaseClass(ARTTIType.AsInstance.MetaclassType);
  for RTTIProperty in G.Properties(BaseClass) do
  if (RTTIProperty.Visibility = mvPublished) And RTTIProperty.PropertyType.IsInstance then
  Begin
    FObjectProperties.TryGetValue(BaseClass, RTTIProperties);
    SetLength(RTTIProperties, Length(RTTIProperties) + 1);
    RTTIProperties[Length(RTTIProperties) - 1] := RTTIProperty;
    FObjectProperties.AddOrSetValue(BaseClass, RTTIProperties);

    PropertyClass := TgIdentityObjectClass(RTTIProperty.PropertyType.AsInstance.MetaclassType);
    if BaseClass.InheritsFrom(TgIdentityObject) And PropertyClass.InheritsFrom(TgIdentityObject) then
    Begin
      FReferences.TryGetValue(PropertyClass, IdentityObjectClassProperties);
      SetLength(IdentityObjectClassProperties, Length(IdentityObjectClassProperties) + 1);
      IdentityObjectClassProperties[Length(IdentityObjectClassProperties) - 1] := TgIdentityObjectClassProperty.Create(TgIdentityObjectClass(BaseClass), RTTIProperty);
      FReferences.AddOrSetValue(PropertyClass, IdentityObjectClassProperties);
    End;

    if PropertyClass.InheritsFrom(TgIdentityList) then
    begin
      FIdentityListProperties.TryGetValue(BaseClass, RTTIProperties);
      SetLength(RTTIProperties, Length(RTTIProperties) + 1);
      RTTIProperties[Length(RTTIProperties) - 1] := RTTIProperty;
      FIdentityListProperties.AddOrSetValue(BaseClass, RTTIProperties);
    end;

  End;
end;

class constructor G.Create;
begin
  DefaultPersistenceManagerClassName := 'gCore.TgPersistenceManagerFile';
  FRTTIContext := TRTTIContext.Create();
  FProperties := TDictionary<TgBaseClass, TArray<TRTTIProperty>>.Create();
  FAttributes := TDictionary<TPair<TgBaseClass, TCustomAttributeClass>, TArray<TCustomAttribute>>.Create();
  FObjectProperties := TDictionary<TgBaseClass, TArray<TRTTIProperty>>.Create();
  FAutoCreateProperties := TDictionary<TgBaseClass, TArray<TRTTIProperty>>.Create();
  FPropertyByName := TDictionary<String, TRTTIProperty>.Create();
  FMethodByName := TDictionary<String, TRTTIMethod>.Create();
  FSerializableProperties := TDictionary < TgBaseClass, TArray < TRTTIProperty >>.Create();
  FRecordProperty := TDictionary<TRTTIProperty, TgRecordProperty>.Create();
  FSerializationHelpers := TDictionary<TgSerializerClass, TList<TPair<TgBaseClass, TgSerializationHelperClass>>>.Create();
  FClassValidationAttributes := TDictionary<TgBaseClass, TArray<Validation>>.Create();
  FCompositeProperties := TDictionary<TgBaseClass, TArray<TRTTIProperty>>.Create();
  FVisibleProperties := TDictionary<TgBaseClass, TArray<TRTTIProperty>>.Create();
  FDisplayPropertyNames := TDictionary<TgBaseClass, TArray<String>>.Create();
  FPersistableProperties := TDictionary<TgBaseClass, TArray<TRTTIProperty>>.Create();
  FPropertyValidationAttributes := TDictionary<TgBaseClass, TArray<TgPropertyValidationAttribute>>.Create();
  FListProperties := TDictionary<TgBaseClass, TArray<TRTTIProperty>>.Create();
  FOwnedAttributes := TObjectList.Create();
  FPropertyAttributes := TDictionary<TgPropertyAttributeClassKey, TArray<TCustomAttribute>>.Create();
  FPersistenceManagers := TDictionary<TgIdentityObjectClass, TgPersistenceManager>.Create();
  FAssignableProperties := TDictionary<TgBaseClass, TArray<TRTTIProperty>>.Create();
  FIdentityListProperties := TDictionary<TgBaseClass, TArray<TRTTIProperty>>.Create();
  FReferences := TDictionary<TgIdentityObjectClass, TArray<TgIdentityObjectClassProperty>>.Create();
  FServers := TDictionary<String, TgServer>.Create();
  FConnectionDescriptors := TDictionary<String, TgConnectionDescriptor>.Create();
end;

class destructor G.Destroy;
var
  PersistenceManager : TgPersistenceManager;
  Server : TgServer;
begin
  FreeAndNil(FConnectionDescriptors);
  for PersistenceManager in FPersistenceManagers.Values do
    PersistenceManager.Free;
  FreeAndNil(FPersistenceManagers);
  for Server in FServers.Values do
    Server.Free;
  FreeAndNil(FServers);
  FreeAndNil(FReferences);
  FreeAndNil(FIdentityListProperties);
  FreeAndNil(FAssignableProperties);
  FreeAndNil(FPersistenceManagers);
  FreeAndNil(FPropertyAttributes);
  FreeAndNil(FOwnedAttributes);
  FreeAndNil(FListProperties);
  FreeAndNil(FPropertyValidationAttributes);
  FreeAndNil(FPersistableProperties);
  FreeAndNil(FDisplayPropertyNames);
  FreeAndNil(FVisibleProperties);
  FreeAndNil(FCompositeProperties);
  FreeAndNil(FClassValidationAttributes);
  FreeAndNil(FSerializationHelpers);
  FreeAndNil(FRecordProperty);
  FreeAndNil(FMethodByName);
  FreeAndNil(FSerializableProperties);
  FreeAndNil(FPropertyByName);
  FreeAndNil(FAutoCreateProperties);
  FreeAndNil(FObjectProperties);
  FreeAndNil(FAttributes);
  FreeAndNil(FProperties);
  FRTTIContext.Free;
end;

class procedure G.AddConnectionDescriptor(AConnectionDescriptor: TgConnectionDescriptor);
begin
  FConnectionDescriptors.AddOrSetValue(AConnectionDescriptor.Name, AConnectionDescriptor);
end;

class procedure G.AddServer(AServer: TgServer);
begin
  FServers.AddOrSetValue(AServer.Name, AServer);
end;

class procedure G.AfterInit(Proc: TProc);
begin
  SetLength(_AfterInit,Length(_AfterInit)+1);
  _AfterInit[High(_AfterInit)] := Proc;
end;

class function G.ApplicationPath(ABaseClass: TgBaseClass): String;
begin
  Result := RootPath+IncludeTrailingPathDelimiter(ABaseClass.UnitName);
end;

class function G.RootPath: String;
begin
  Result := G.SpecialFolder(sfCommonAppData) + IncludeTrailingPathDelimiter('G');
end;

class function G.AssignableProperties(ABaseClass: TgBaseClass): TArray<TRTTIProperty>;
begin
  FAssignableProperties.TryGetValue(ABaseClass, Result);
end;

class function G.AssignableProperties(ABase: TgBase): TArray<TRTTIProperty>
;
begin
  Result := AssignableProperties(TgBaseClass(ABase.ClassType));
end;

class function G.Attributes(ABaseClass: TgBaseClass; AAttributeClass: TCustomAttributeClass): TArray<TCustomAttribute>;
var
  Pair : TPair<TgBaseClass, TCustomAttributeClass>;
begin
  Pair.Key := ABaseClass;
  Pair.Value := AAttributeClass;
  FAttributes.TryGetValue(Pair, Result);
end;

class function G.Attributes(ABase: TgBase; AAttributeClass: TCustomAttributeClass): Tarray<TCustomAttribute>;
begin
  Result := Attributes(TgBaseClass(ABase.ClassType), AAttributeClass);
end;

class function G.AutoCreateProperties(AInstance: TgBase): TArray<TRTTIProperty>;
begin
  Result := AutoCreateProperties(TgBaseClass(AInstance.ClassType));
end;

class function G.AutoCreateProperties(AClass: TgBaseClass): TArray<TRTTIProperty>;
begin
  FAutoCreateProperties.TryGetValue(AClass, Result);
end;

class function G.ClassByName(const AName: String): TgBaseClass;
var
  RTTIType: TRTTIType;
begin
  Result := Nil;
  RTTIType := FRTTIContext.FindType(AName);
  if Assigned(RTTIType) And RTTIType.IsInstance And RTTIType.AsInstance.MetaclassType.InheritsFrom(TgBase) then
    Result := TgBaseClass(RTTIType.AsInstance.MetaclassType);
end;

class function G.CompositeProperties(AClass: TgBaseClass): TArray<TRTTIProperty>;
begin
  FCompositeProperties.TryGetValue(AClass, Result);
end;

class function G.CompositeProperties(ABase: TgBase): TArray<TRTTIProperty>;
begin
  Result := CompositeProperties(TgBaseClass(ABase.ClassType));
end;

class function G.DisplayPropertyNames(AClass: TgBaseClass): TArray<String>;
begin
  FDisplayPropertyNames.TryGetValue(AClass, Result);
end;

class procedure G.DoAfterInit;
var Proc: TProc;
begin
  for Proc in _AfterInit do
    Proc;
  SetLength(_AfterInit,0);
end;

class procedure G.InitializePersistableProperties(ARTTIType: TRTTIType);
var
  BaseClass: TgBaseClass;
  RTTIProperties: TArray<TRTTIProperty>;
  RTTIProperty: TRTTIProperty;
begin
  BaseClass := TgBaseClass(ARTTIType.AsInstance.MetaclassType);
  for RTTIProperty in SerializableProperties(BaseClass) do
  begin
    FPersistableProperties.TryGetValue(BaseClass, RTTIProperties);
    SetLength(RTTIProperties, Length(RTTIProperties) + 1);
    RTTIProperties[Length(RTTIProperties) - 1] := RTTIProperty;
    FPersistableProperties.AddOrSetValue(BaseClass, RTTIProperties);
  end;
end;

class procedure G.InitializeDisplayPropertyNames(ARTTIType: TRTTIType);
var
  BaseClass: TgBaseClass;
  CustomAttributes: TArray<TCustomAttribute>;
  DisplayPropertyNames: TArray<String>;
  RTTIProperty: TRTTIProperty;
begin
  BaseClass := TgBaseClass(ARTTIType.AsInstance.MetaclassType);
  CustomAttributes := Attributes(BaseClass, gCore.DisplayPropertyNames);
  if Length(CustomAttributes) > 0 then
  begin
    DisplayPropertyNames := gCore.DisplayPropertyNames(CustomAttributes[0]).Value;
    FDisplayPropertyNames.AddOrSetValue(BaseClass, DisplayPropertyNames);
  end
  Else
  for RTTIProperty in G.VisibleProperties(BaseClass) do
  begin
    if Not RTTIProperty.PropertyType.IsInstance then
    Begin
      SetLength(DisplayPropertyNames, 1);
      DisplayPropertyNames[0] := RTTIProperty.Name;
      FDisplayPropertyNames.AddOrSetValue(BaseClass, DisplayPropertyNames);
    End;
  end;
end;

class procedure G.InitializeMethodByName(ARTTIType: TRTTIType);
var
  Key: String;
  RTTIMethod: TRTTIMethod;
begin
  for RTTIMethod in ARTTIType.GetMethods do
  if (RTTIMethod.Visibility = mvPublished) And (Length(RTTIMethod.GetParameters) = 0) then
  begin
    Key := ARTTIType.AsInstance.MetaclassType.ClassName + '.' + UpperCase(RTTIMethod.Name);
    FMethodByName.AddOrSetValue(Key, RTTIMethod);
  end;
end;

class procedure G.InitializeProperties(ARTTIType: TRTTIType);
var
  Temp,
  RTTIProperties: TArray<TRTTIProperty>;
  BaseClass: TgBaseClass;
  RTTIProperty: TRTTIProperty;
  Counter: Integer;
  Replaced: Boolean;
  Index: Integer;
  IsParents: Boolean;
begin
  BaseClass := TgBaseClass(ARTTIType.AsInstance.MetaclassType);
  //Include all the ancestor properties
  IsParents := (BaseClass <> TgBase) and FProperties.TryGetValue(TgBaseClass(BaseClass.ClassParent), RTTIProperties);
  //For each new property
  for RTTIProperty in ARTTIType.GetDeclaredProperties do
  if RTTIProperty.Visibility = mvPublished then
  begin
    Replaced := False;
    for Counter := 0 to Length(RTTIProperties) - 1 do
    Begin
      //If the property is re-introduced
      if SameText(RTTIProperty.Name, RTTIProperties[Counter].Name) then
      Begin
        //Substitute the ancestor property with the declared one
         if IsParents then begin
           IsParents := False;
           // Copy the array
           SetLength(Temp,Length(RTTIProperties));
           for Index := 0 to High(Temp) do
             Temp[Index] := RTTIProperties[Index];
           RTTIProperties := Temp;
        end;
        RTTIProperties[Counter] := RTTIProperty;
        Replaced := True;
        Break;
      End;
    End;
    if Not Replaced then
    Begin
      SetLength(RTTIProperties, Length(RTTIProperties) + 1);
      RTTIProperties[Length(RTTIProperties) - 1] := RTTIProperty;
    End;
  end;
  FProperties.AddOrSetValue(BaseClass, RTTIProperties);
end;

class procedure G.InitializePropertyByName(ARTTIType: TRTTIType);
var
  BaseClass: TgBaseClass;
  RTTIProperty: TRTTIProperty;
  Key : String;
begin
  BaseClass := TgBaseClass(ARTTIType.AsInstance.MetaclassType);
  for RTTIProperty in G.Properties(BaseClass) do
  if RTTIProperty.Visibility = mvPublished then
  begin
    Key := BaseClass.ClassName + '.' + UpperCase(RTTIProperty.Name);
    FPropertyByName.Add(Key, RTTIProperty);
  end;
end;

class procedure G.InitializePropertyValidationAttributes(ARTTIType: TRTTIType);
var
  RTTIProperty: TRTTIProperty;
  Attribute: TCustomAttribute;
  BaseClass: TgBaseClass;
  PropertyValidationAttribute: TgPropertyValidationAttribute;
  PropertyValidationAttributes: TArray<TgPropertyValidationAttribute>;

  procedure AddAttribute;
  begin
    FPropertyValidationAttributes.TryGetValue(BaseClass, PropertyValidationAttributes);
    SetLength(PropertyValidationAttributes, Length(PropertyValidationAttributes) + 1);
    PropertyValidationAttribute.RTTIProperty := RTTIProperty;
    PropertyValidationAttribute.ValidationAttribute := Validation(Attribute);
    PropertyValidationAttributes[Length(PropertyValidationAttributes) - 1] := PropertyValidationAttribute;
    FPropertyValidationAttributes.AddOrSetValue(BaseClass, PropertyValidationAttributes);
  end;

begin
  BaseClass := TgBaseClass(ARTTIType.AsInstance.MetaclassType);
  for RTTIProperty in Properties(BaseClass) do
  begin
    for Attribute in RTTIProperty.GetAttributes do
    if Attribute.InheritsFrom(Validation) then
      AddAttribute;
    try
      for Attribute in RTTIProperty.PropertyType.GetAttributes do
      if Attribute.InheritsFrom(Validation) then
        AddAttribute;
    except
      on e: exception do begin
        e.Message := format('%s: Attribute Error: RTTIProperty[%s] RTTIPropertyClass[%s] PropertyType[%s]',[e.Message,RTTIProperty.Name,RTTIProperty.ClassName,RTTIProperty.PropertyType.Name]);
        raise;
      end;
    end;
    // Identity objects should be given the Required attribute unless it is specifically disabled
    if RTTIProperty.PropertyType.IsInstance and RTTIProperty.PropertyType.AsInstance.MetaclassType.InheritsFrom(TgIdentityObject) And (Length(PropertyAttributes(TgPropertyAttributeClassKey.Create(RTTIProperty, NotRequired))) = 0) then
    Begin
      Attribute := Required.Create;
      FOwnedAttributes.Add(Attribute);
      AddAttribute;
    End;
  end;
end;

class procedure G.InitializeRecordProperty(ARTTIType: TRTTIType);
var
  CanAdd: Boolean;
  RecordProperty: TgRecordProperty;
  RTTIProperty: TRTTIProperty;
begin
  for RTTIProperty in G.Properties(TgBaseClass(ARTTIType.AsInstance.MetaclassType)) do
  if (RTTIProperty.Visibility = mvPublished) And (RTTIProperty.PropertyType.IsRecord) then
  begin
    CanAdd := True;
    if RTTIProperty.IsReadable Then
    begin
      RecordProperty.Getter := RTTIProperty.PropertyType.AsRecord.GetMethod('GetValue');
      CanAdd := Assigned(RecordProperty.Getter);
    end;
    if CanAdd And RTTIProperty.IsWritable then
    begin
      RecordProperty.Setter := RTTIProperty.PropertyType.AsRecord.GetMethod('SetValue');
      CanAdd := Assigned(RecordProperty.Setter);
    end;
    if CanAdd then
    Begin
      RecordProperty.Validator := RTTIProperty.PropertyType.AsRecord.GetMethod('Validation');
      FRecordProperty.AddOrSetValue(RTTIProperty, RecordProperty);
    End;
  end;
end;

class procedure G.InitializeSerializationHelpers(ARTTIType: TRTTIType);
var
  BaseClass: TgBaseClass;
  List: TList<TPair<TgBaseClass, TgSerializationHelperClass>>;
  SerializationHelperClass: TgSerializationHelperClass;
  Pair: TPair<TgBaseClass, TgSerializationHelperClass>;
  SerializerClass: TgSerializerClass;
  Comparer: TgSerializer.THelper.TComparer;
  Method: TRTTIMethod;
begin

  SerializationHelperClass := TgSerializationHelperClass(ARTTIType.AsInstance.MetaclassType);

  Method := ARTTIType.AsInstance.GetMethod('BaseClass');
  if Method.CodeAddress = @TgSerializer.THelper.BaseClass then
    exit;// Abstract method do not track this class
  if Method.CodeAddress = @TgSerializer.THelper.Deserialize then
    exit;// Abstract method do not track this class

  SerializerClass := SerializationHelperClass.SerializerClass;
  BaseClass := TgSerializationHelperClass(ARTTIType.AsInstance.MetaclassType).BaseClass;
  FSerializationHelpers.TryGetValue(SerializerClass, List);
  if Not Assigned(List) then
    List := TList<TPair<TgBaseClass, TgSerializationHelperClass>>.Create;
  Pair.Create(BaseClass, SerializationHelperClass);
  List.Add(Pair);

  Comparer := TgSerializer.THelper.TComparer.Create;
  try
    List.Sort(Comparer);
  finally
    Comparer.Free;
  end;

  FSerializationHelpers.AddOrSetValue(SerializerClass, List);
end;

class function G.MethodByName(ABaseClass: TgBaseClass; const AName: String): TRTTIMethod;
var
  Key: String;
begin
  Key := ABaseClass.ClassName + '.' + UpperCase(AName);
  FMethodByName.TryGetValue(Key, Result);
end;

class function G.MethodByName(ABase: TgBase; const AName: String): TRTTIMethod;
begin
  Result := MethodByName(TgBaseClass(ABase.ClassType), AName);
end;

class function G.ObjectProperties(AInstance: TgBase): TArray<TRTTIProperty>;
begin
  Result := ObjectProperties(TgBaseClass(AInstance.ClassType));
end;

class function G.ObjectProperties(AClass: TgBaseClass): TArray<TRTTIProperty>;
begin
  FObjectProperties.TryGetValue(AClass, Result);
end;

class function G.PersistableProperties(ABaseClass: TgBaseClass): TArray<TRTTIProperty>;
begin
  FPersistableProperties.TryGetValue(ABaseClass, Result);
end;

class function G.PersistableProperties(ABase: TgBase): TArray<TRTTIProperty>;
begin
  Result := PersistableProperties(TgBaseClass(ABase.ClassType));
end;

class function G.Properties(AClass: TgBaseClass): TArray<TRTTIProperty>;
begin
  FProperties.TryGetValue(AClass, Result);
end;

class function G.PropertyByName(AClass: TgBaseClass; const AName: String): TRTTIProperty;
var
  Key : String;
begin
  Key := AClass.ClassName + '.' + UpperCase(AName);
  if not FPropertyByName.TryGetValue(Key, Result) then
    Result := nil;
end;

class function G.PropertyByName(ABase: TgBase; const AName: String): TRTTIProperty;
begin
  Result := PropertyByName(TgBaseClass(ABase.ClassType), AName);
end;

class function G.PropertyValidationAttributes(ABaseClass: TgBaseClass): TArray<TgPropertyValidationAttribute>;
begin
  FPropertyValidationAttributes.TryGetValue(ABaseClass, Result);
end;

class function G.PropertyValidationAttributes(ABase: TgBase): TArray<TgPropertyValidationAttribute>;
begin
  Result := PropertyValidationAttributes(TgBaseClass(ABase.ClassType));
end;

class function G.RecordProperty(ARTTIProperty: TRTTIProperty): TgRecordProperty;
begin
  FRecordProperty.TryGetValue(ARTTIProperty, Result);
end;

class function G.SerializableProperties(ABase: TgBase): TArray<TRTTIProperty>;
Begin
  Result := SerializableProperties(TgBaseClass(ABase.ClassType));
End;

class function G.SerializableProperties(AClass : TgBaseClass): TArray<TRTTIProperty>;
Begin
  FSerializableProperties.TryGetValue(AClass, Result);
End;

class function G.SerializationHelpers(ASerializerClass: TgSerializerClass; AObject: TgBase): TgSerializationHelperClass;
var
  Pair: TPair<TgBaseClass, TgSerializationHelperClass>;
  List : TList<TPair<TgBaseClass, TgSerializationHelperClass>>;
begin
  Result := Nil;
  FSerializationHelpers.TryGetValue(ASerializerClass, List);
  for Pair in List do
  begin
    if AObject.InheritsFrom(Pair.Key) then
    Begin
      Result := Pair.Value;
      Break;
    End;
  end;
end;

class function G.ClassValidationAttributes(AClass: TgBaseClass): TArray<Validation>;
begin
  FClassValidationAttributes.TryGetValue(AClass, Result);
end;

class function G.ClassValidationAttributes(ABase: TgBase): TArray<Validation>;
begin
  Result := ClassValidationAttributes(TgBase(ABase.ClassType));
end;

class function G.ConnectionDescriptor(const AName: String): TgConnectionDescriptor;
begin
  FConnectionDescriptors.TryGetValue(AName, Result);;
end;

class function G.DataPath(ABaseClass: TgBaseClass): String;
begin
  Result := ABaseClass.ApplicationPath + IncludeTrailingPathDelimiter('Data');
end;

class function G.DataPath: String;
begin
  Result := RootPath + IncludeTrailingPathDelimiter('Data');
end;

class procedure G.Finalize;
begin
  // TODO -cMM: G.Finalize default body inserted
end;

class function G.IdentityListProperties(ABaseClass: TgBaseClass): TArray<TRTTIProperty>;
begin
  FIdentityListProperties.TryGetValue(ABaseClass, Result);
end;

class function G.IdentityListProperties(ABase: TgBase): TArray<TRTTIProperty>;
begin
  Result := IdentityListProperties(TgBaseClass(ABase.ClassType));
end;

class procedure G.InitializeAssignableProperties(ARTTIType: TRTTIType);
Var
  BaseClass: TgBaseClass;
  PropertyAttributeClassKey: TgPropertyAttributeClassKey;
  RTTIProperties: TArray<TRTTIProperty>;
  RTTIProperty : TRTTIProperty;
Begin
  BaseClass := TgBaseClass(ARTTIType.AsInstance.MetaclassType);
  for RTTIProperty in G.Properties(BaseClass) do
  begin
    PropertyAttributeClassKey.RTTIProperty := RTTIProperty;
    PropertyAttributeClassKey.AttributeClass := NotAssignable;
    if (RTTIProperty.Visibility = mvPublished) And RTTIProperty.IsReadable
      And (Length(PropertyAttributes(PropertyAttributeClassKey)) = 0)
      And
        (
            (RTTIProperty.PropertyType.IsInstance And RTTIProperty.PropertyType.AsInstance.MetaclassType.InheritsFrom(TgBase))
          Or
            (Not RTTIProperty.PropertyType.IsInstance And RTTIProperty.IsWritable)
        )
    then
    begin
      FAssignableProperties.TryGetValue(BaseClass, RTTIProperties);
      SetLength(RTTIProperties, Length(RTTIProperties) + 1);
      RTTIProperties[Length(RTTIProperties) - 1] := RTTIProperty;
      FAssignableProperties.AddOrSetValue(BaseClass, RTTIProperties);
    end;
  end;
end;

class procedure G.InitializeAutoCreate(ARTTIType: TRTTIType);
Var
  RTTIProperty : TRTTIProperty;
  BaseClass: TgBaseClass;
  PropertyAttributeClassKey: TgPropertyAttributeClassKey;
  RTTIProperties: TArray<TRTTIProperty>;
Begin
  BaseClass := TgBaseClass(ARTTIType.AsInstance.MetaclassType);
  for RTTIProperty in G.ObjectProperties(BaseClass) do
  begin
    PropertyAttributeClassKey.RTTIProperty := RTTIProperty;
    PropertyAttributeClassKey.AttributeClass := NotAutoCreate;
    If Not RTTIProperty.IsWritable And IsField(TRTTIInstanceProperty(RTTIProperty).PropInfo^.GetProc) And (Length(PropertyAttributes(PropertyAttributeClassKey)) = 0) Then
    Begin
      FAutoCreateProperties.TryGetValue(BaseClass, RTTIProperties);
      SetLength(RTTIProperties, Length(RTTIProperties) + 1);
      RTTIProperties[Length(RTTIProperties) - 1] := RTTIProperty;
      FAutoCreateProperties.AddOrSetValue(BaseClass, RTTIProperties);
    End;
  end;
end;

class procedure G.InitializeCompositeProperties(ARTTIType: TRTTIType);
var
  BaseClass: TgBaseClass;
  RTTIProperties: TArray<TRTTIProperty>;
  RTTIProperty: TRTTIProperty;
begin
  BaseClass := TgBaseClass(ARTTIType.AsInstance.MetaclassType);
  for RTTIProperty in ObjectProperties(BaseClass) do
  if IsComposite(RTTIProperty) then
  begin
    FCompositeProperties.TryGetValue(BaseClass, RTTIProperties);
    SetLength(RTTIProperties, Length(RTTIProperties) + 1);
    RTTIProperties[Length(RTTIProperties) - 1] := RTTIProperty;
    FCompositeProperties.AddOrSetValue(BaseClass, RTTIProperties);
  end;
end;

class procedure G.InitializePersistenceManager(ARTTIType: TRTTIType);
var
  FileName: string;
  IdentityObjectClass: TgIdentityObjectClass;
  PersistenceManager: TgPersistenceManager;
  PersistenceManagerAliasAttribute: PersistenceManagerClassName;
  PersistenceManagerAliasAttributes: TArray<TCustomAttribute>;
  PersistenceManagerClass: TgBaseClass;
  PMClassName: string;
begin
  IdentityObjectClass := TgIdentityObjectClass(ARTTIType.AsInstance.MetaclassType);
  if (IdentityObjectClass <> TgIdentityObject) And IdentityObjectClass.InheritsFrom(TgIdentityObject) then
  Begin
    FileName := Format('%s%s.xml', [G.PersistenceManagerPath, IdentityObjectClass.FriendlyName]);
    if FileExists(FileName) then
    Begin
      PersistenceManager := TgPersistenceManager(CreateAndDeserializeFromFile(TgSerializerXML, FileName));
      PersistenceManager.ForClass := IdentityObjectClass;
      FPersistenceManagers.AddOrSetValue(IdentityObjectClass, PersistenceManager);
    End
    Else
    Begin
      PersistenceManagerAliasAttributes := Attributes(IdentityObjectClass, PersistenceManagerClassName);
      if Length(PersistenceManagerAliasAttributes) > 0 then
      Begin
        PersistenceManagerAliasAttribute := PersistenceManagerClassName(PersistenceManagerAliasAttributes[0]);
        PMClassName := PersistenceManagerAliasAttribute.Value;
      End
      Else
        PMClassName := DefaultPersistenceManagerClassName;
      PersistenceManagerClass := ClassByName(PMClassName);

      PersistenceManager := TgPersistenceManagerClass(PersistenceManagerClass).Create;
      PersistenceManager.ForClass := IdentityObjectClass;
      FPersistenceManagers.AddOrSetValue(IdentityObjectClass, PersistenceManager);
//      PersistenceManager.Configure;
//      StringToFile(PersistenceManager.Serialize(TgSerializerXML), FileName);
    End;
  End;
end;

class procedure G.InitializeSerializableProperties(ARTTIType: TRTTIType);
Var
  BaseClass: TgBaseClass;
  PropertyAttributeClassKey: TgPropertyAttributeClassKey;
  SerializableAttribute: TgPropertyAttributeClassKey;
  RTTIProperties: TArray<TRTTIProperty>;
  RTTIProperty : TRTTIProperty;
Begin
  BaseClass := TgBaseClass(ARTTIType.AsInstance.MetaclassType);
  for RTTIProperty in G.Properties(BaseClass) do
  begin
    PropertyAttributeClassKey.RTTIProperty := RTTIProperty;
    PropertyAttributeClassKey.AttributeClass := NotSerializable;
    SerializableAttribute.RTTIProperty := RTTIProperty;
    SerializableAttribute.AttributeClass := Serializable;
    if (RTTIProperty.Visibility = mvPublished) And RTTIProperty.IsReadable
      And (Length(PropertyAttributes(PropertyAttributeClassKey)) = 0)
      And ((Length(PropertyAttributes(SerializableAttribute)) <> 0) or Not RTTIProperty.PropertyType.IsInstance or Not RTTIProperty.PropertyType.AsInstance.MetaclassType.InheritsFrom(TgIdentityList))
      And
        (
            (RTTIProperty.PropertyType.IsInstance And RTTIProperty.PropertyType.AsInstance.MetaclassType.InheritsFrom(TgBase))
          Or
            (Not RTTIProperty.PropertyType.IsInstance And RTTIProperty.IsWritable)
        )
    then
    begin
      FSerializableProperties.TryGetValue(BaseClass, RTTIProperties);
      SetLength(RTTIProperties, Length(RTTIProperties) + 1);
      RTTIProperties[Length(RTTIProperties) - 1] := RTTIProperty;
      FSerializableProperties.AddOrSetValue(BaseClass, RTTIProperties);
    end;
  end;
end;

class procedure G.InitializeVisibleProperties(ARTTIType: TRTTIType);
var
  BaseClass: TgBaseClass;
  RTTIProperties: TArray<TRTTIProperty>;
  RTTIProperty: TRTTIProperty;
begin
  BaseClass := TgBaseClass(ARTTIType.AsInstance.MetaclassType);
  for RTTIProperty in Properties(BaseClass) do
  if (RTTIProperty.Visibility = mvPublished) and (Length(PropertyAttributes(TgPropertyAttributeClassKey.Create(RTTIProperty, NotVisible))) = 0) then
  begin
    FVisibleProperties.TryGetValue(BaseClass, RTTIProperties);
    SetLength(RTTIProperties, Length(RTTIProperties) + 1);
    RTTIProperties[Length(RTTIProperties) - 1] := RTTIProperty;
    FVisibleProperties.AddOrSetValue(BaseClass, RTTIProperties);
  end;
end;

class function G.IsComposite(ARTTIProperty: TRTTIProperty): Boolean;
var
  BaseClass: TClass;
begin
  BaseClass := ARTTIProperty.Parent.AsInstance.MetaclassType;
  Result := (Length(PropertyAttributes(TgPropertyAttributeClassKey.Create(ARTTIProperty, Composite))) > 0) Or (Not ARTTIProperty.IsWritable And Not (BaseClass.InheritsFrom(TgIdentityObject) or BaseClass.InheritsFrom(TgIdentityList)) And (Length(PropertyAttributes(TgPropertyAttributeClassKey.Create(ARTTIProperty, NotComposite))) = 0));
end;

class procedure G.LoadPackages(APackageNames: TStrings);
var
  PackageName: String;
begin
  for PackageName in APackageNames do
    LoadPackage(PackageName);
end;

class procedure G.LoadPackages(const APackageNames: TArray<String>);
var
  PackageName: String;
begin
  for PackageName in APackageNames do
    LoadPackage(PackageName);
end;

class function G.PersistenceManagerPath: String;
begin
  Result := IncludeTrailingPathDelimiter(RootPath + 'PersistenceManagers');
end;

class function G.PersistenceManager(AIdentityObjectClass: TgIdentityObjectClass): TgPersistenceManager;
begin
  FPersistenceManagers.TryGetValue(AIdentityObjectClass, Result);
end;

class function G.PersistenceManagers: TDictionary<TgIdentityObjectClass, TgPersistenceManager>.TValueCollection;
begin
  Result := FPersistenceManagers.Values;
end;

class function G.PropertyAttributes(APropertyAttributeClassKey: TgPropertyAttributeClassKey): TArray<TCustomAttribute>;
begin
  FPropertyAttributes.TryGetValue(APropertyAttributeClassKey, Result);
end;

class function G.References(AIdentityObjectClass: TgIdentityObjectClass): TArray<TgIdentityObjectClassProperty>;
begin
  FReferences.TryGetValue(AIdentityObjectClass, Result);
end;

class function G.References(AIdentityObject: TgIdentityObject): TArray<TgIdentityObjectClassProperty>;
begin
  Result := References(TgIdentityObjectClass(AIdentityObject.ClassType));;
end;

class function G.Server(const AName: String): TgServer;
begin
  FServers.TryGetValue(AName, Result);
end;

class function G.SpecialFolder(Index: TSpecialFolder): String;
var
  windir: array[0..MAX_PATH] of char;
  nFolder: Word;
begin
  case Index of
    sfCommonAppData: nFolder := CSIDL_COMMON_APPDATA;
    else
      Result := '';
  end;

(*
  CSIDL_DESKTOP                 = $0000;          // <desktop>
  {$EXTERNALSYM CSIDL_DESKTOP}
  CSIDL_INTERNET                = $0001;          // Internet Explorer (icon on desktop)
  {$EXTERNALSYM CSIDL_INTERNET}
  CSIDL_PROGRAMS                = $0002;          // Start Menu\Programs
  {$EXTERNALSYM CSIDL_PROGRAMS}
  CSIDL_CONTROLS                = $0003;          // My Computer\Control Panel
  {$EXTERNALSYM CSIDL_CONTROLS}
  CSIDL_PRINTERS                = $0004;          // My Computer\Printers
  {$EXTERNALSYM CSIDL_PRINTERS}
  CSIDL_PERSONAL                = $0005;          // My Documents
  {$EXTERNALSYM CSIDL_PERSONAL}
  CSIDL_FAVORITES               = $0006;          // <user name>\Favorites
  {$EXTERNALSYM CSIDL_FAVORITES}
  CSIDL_STARTUP                 = $0007;          // Start Menu\Programs\Startup
  {$EXTERNALSYM CSIDL_STARTUP}
  CSIDL_RECENT                  = $0008;          // <user name>\Recent
  {$EXTERNALSYM CSIDL_RECENT}
  CSIDL_SENDTO                  = $0009;          // <user name>\SendTo
  {$EXTERNALSYM CSIDL_SENDTO}
  CSIDL_BITBUCKET               = $000a;          // <desktop>\Recycle Bin
  {$EXTERNALSYM CSIDL_BITBUCKET}
  CSIDL_STARTMENU               = $000b;          // <user name>\Start Menu
  {$EXTERNALSYM CSIDL_STARTMENU}
  CSIDL_MYDOCUMENTS             = CSIDL_PERSONAL; // Personal was just a silly name for My Documents
  {$EXTERNALSYM CSIDL_MYDOCUMENTS}
  CSIDL_MYMUSIC                 = $000d;          // "My Music" folder
  {$EXTERNALSYM CSIDL_MYMUSIC}
  CSIDL_MYVIDEO                 = $000e;          // "My Videos" folder
  {$EXTERNALSYM CSIDL_MYVIDEO}
  CSIDL_DESKTOPDIRECTORY        = $0010;          // <user name>\Desktop
  {$EXTERNALSYM CSIDL_DESKTOPDIRECTORY}
  CSIDL_DRIVES                  = $0011;          // My Computer
  {$EXTERNALSYM CSIDL_DRIVES}
  CSIDL_NETWORK                 = $0012;          // Network Neighborhood (My Network Places)
  {$EXTERNALSYM CSIDL_NETWORK}
  CSIDL_NETHOOD                 = $0013;          // <user name>\nethood
  {$EXTERNALSYM CSIDL_NETHOOD}
  CSIDL_FONTS                   = $0014;          // windows\fonts
  {$EXTERNALSYM CSIDL_FONTS}
  CSIDL_TEMPLATES               = $0015;
  {$EXTERNALSYM CSIDL_TEMPLATES}
  CSIDL_COMMON_STARTMENU        = $0016;          // All Users\Start Menu
  {$EXTERNALSYM CSIDL_COMMON_STARTMENU}
  CSIDL_COMMON_PROGRAMS         = $0017;          // All Users\Start Menu\Programs
  {$EXTERNALSYM CSIDL_COMMON_PROGRAMS}
  CSIDL_COMMON_STARTUP          = $0018;          // All Users\Startup
  {$EXTERNALSYM CSIDL_COMMON_STARTUP}
  CSIDL_COMMON_DESKTOPDIRECTORY = $0019;          // All Users\Desktop
  {$EXTERNALSYM CSIDL_COMMON_DESKTOPDIRECTORY}
  CSIDL_APPDATA                 = $001a;          // <user name>\Application Data
  {$EXTERNALSYM CSIDL_APPDATA}
  CSIDL_PRINTHOOD               = $001b;          // <user name>\PrintHood
  {$EXTERNALSYM CSIDL_PRINTHOOD}
  CSIDL_LOCAL_APPDATA           = $001c;          // <user name>\Local Settings\Applicaiton Data (non roaming)
  {$EXTERNALSYM CSIDL_LOCAL_APPDATA}
  CSIDL_ALTSTARTUP              = $001d;          // non localized startup
  {$EXTERNALSYM CSIDL_ALTSTARTUP}
  CSIDL_COMMON_ALTSTARTUP       = $001e;          // non localized common startup
  {$EXTERNALSYM CSIDL_COMMON_ALTSTARTUP}
  CSIDL_COMMON_FAVORITES        = $001f;
  {$EXTERNALSYM CSIDL_COMMON_FAVORITES}
  CSIDL_INTERNET_CACHE          = $0020;
  {$EXTERNALSYM CSIDL_INTERNET_CACHE}
  CSIDL_COOKIES                 = $0021;
  {$EXTERNALSYM CSIDL_COOKIES}
  CSIDL_HISTORY                 = $0022;
  {$EXTERNALSYM CSIDL_HISTORY}
  CSIDL_COMMON_APPDATA          = $0023;          // All Users\Application Data
  {$EXTERNALSYM CSIDL_COMMON_APPDATA}
  CSIDL_WINDOWS                 = $0024;          // GetWindowsDirectory()
  {$EXTERNALSYM CSIDL_WINDOWS}
  CSIDL_SYSTEM                  = $0025;          // GetSystemDirectory()
  {$EXTERNALSYM CSIDL_SYSTEM}
  CSIDL_PROGRAM_FILES           = $0026;          // C:\Program Files
  {$EXTERNALSYM CSIDL_PROGRAM_FILES}
  CSIDL_MYPICTURES              = $0027;          // C:\Program Files\My Pictures
  {$EXTERNALSYM CSIDL_MYPICTURES}
  CSIDL_PROFILE                 = $0028;          // USERPROFILE
  {$EXTERNALSYM CSIDL_PROFILE}
  CSIDL_SYSTEMX86               = $0029;          // x86 system directory on RISC
  {$EXTERNALSYM CSIDL_SYSTEMX86}
  CSIDL_PROGRAM_FILESX86        = $002a;          // x86 C:\Program Files on RISC
  {$EXTERNALSYM CSIDL_PROGRAM_FILESX86}
  CSIDL_PROGRAM_FILES_COMMON    = $002b;          // C:\Program Files\Common
  {$EXTERNALSYM CSIDL_PROGRAM_FILES_COMMON}
  CSIDL_PROGRAM_FILES_COMMONX86 = $002c;          // x86 Program Files\Common on RISC
  {$EXTERNALSYM CSIDL_PROGRAM_FILES_COMMONX86}
  CSIDL_COMMON_TEMPLATES        = $002d;          // All Users\Templates
  {$EXTERNALSYM CSIDL_COMMON_TEMPLATES}
  CSIDL_COMMON_DOCUMENTS        = $002e;          // All Users\Documents
  {$EXTERNALSYM CSIDL_COMMON_DOCUMENTS}
  CSIDL_COMMON_ADMINTOOLS       = $002f;          // All Users\Start Menu\Programs\Administrative Tools
  {$EXTERNALSYM CSIDL_COMMON_ADMINTOOLS}
  CSIDL_ADMINTOOLS              = $0030;          // <user name>\Start Menu\Programs\Administrative Tools
  {$EXTERNALSYM CSIDL_ADMINTOOLS}
  CSIDL_CONNECTIONS             = $0031;          // Network and Dial-up Connections
  {$EXTERNALSYM CSIDL_CONNECTIONS}
  CSIDL_COMMON_MUSIC            = $0035;          // All Users\My Music
  {$EXTERNALSYM CSIDL_COMMON_MUSIC}
  CSIDL_COMMON_PICTURES         = $0036;          // All Users\My Pictures
  {$EXTERNALSYM CSIDL_COMMON_PICTURES}
  CSIDL_COMMON_VIDEO            = $0037;          // All Users\My Video
  {$EXTERNALSYM CSIDL_COMMON_VIDEO}
  CSIDL_RESOURCES               = $0038;          // Resource Direcotry
  {$EXTERNALSYM CSIDL_RESOURCES}
  CSIDL_RESOURCES_LOCALIZED     = $0039;          // Localized Resource Direcotry
  {$EXTERNALSYM CSIDL_RESOURCES_LOCALIZED}
  CSIDL_COMMON_OEM_LINKS        = $003a;          // Links to All Users OEM specific apps
  {$EXTERNALSYM CSIDL_COMMON_OEM_LINKS}
  CSIDL_CDBURN_AREA             = $003b;          // USERPROFILE\Local Settings\Application Data\Microsoft\CD Burning
*)
  if not SHGetSpecialFolderPath(0,@Windir,nFolder,FALSE) then
    Result := ''
  else
    Result := IncludeTrailingPathDelimiter(Windir);
end;

class function G.VisibleProperties(ABaseClass: TgBaseClass): TArray<TRTTIProperty>;
begin
  FVisibleProperties.TryGetValue(ABaseClass, Result);
end;

{ DefaultValue }

Constructor DefaultValue.Create(AValue : Double);
Begin
  FValue := AValue;
End;

Constructor DefaultValue.Create(AValue : Integer);
Begin
  FValue := AValue;
End;

Constructor DefaultValue.Create(Const AValue : String);
Begin
  FValue := AValue;
End;

Constructor DefaultValue.Create(AValue : TDateTime);
Begin
  FValue := AValue;
End;

procedure DefaultValue.Execute(ABase: TgBase);
begin
  ABase[RTTIProperty.Name] := Value;
end;

constructor DefaultValue.Create(AValue: Boolean);
begin
  FValue := AValue;
end;

{ TgSerializer }

constructor TgSerializer.Create;
begin
  inherited Create;
end;

function TgSerializer.CreateAndDeserialize(const AString: String; AOwner: TgBase = Nil): TgBase;
var
  BaseClass: TgBaseClass;
  BaseClassName: String;
begin
  BaseClassName := ExtractClassName(AString);
  BaseClass := G.ClassByName(BaseClassName);
  if Assigned(BaseClass) then
  Begin
    Result := BaseClass.Create(AOwner);
    Deserialize(Result, AString);
  End
  Else
    raise E.CreateFmt('Serializer could not find class %s in which to deserialize.', [BaseClassName]);
end;

{ TgSerializerXML }

procedure TgSerializerXML.AddObjectProperty(ARTTIProperty: TRTTIProperty; AObject: TgBase);
var
  HelperClass: TgSerializationHelperClass;
begin
  TemporaryCurrentNode(CurrentNode.AddChild(ARTTIProperty.Name),procedure
    begin
      if ARTTIProperty.PropertyType.IsInstance then
        if ARTTIProperty.PropertyType.AsInstance.MetaclassType <> AObject.ClassType then
          CurrentNode.Attributes['classname'] := AObject.QualifiedClassName;
      HelperClass := G.SerializationHelpers(TgSerializerXML, AObject);
      HelperClass.Serialize(AObject, Self, ARTTIProperty);
    end);
end;
procedure TgSerializerXML.AddValueProperty(const AName: String; AValue: Variant);
var
  ChildNode: IXMLNode;
begin
  ChildNode := CurrentNode.AddChild(AName);
  ChildNode.Text := AValue;
end;

constructor TgSerializerXML.Create;
begin
  inherited Create;
  FDocument := TXMLDocument.Create(Nil);
  FDocumentInterface := FDocument;
  FDocument.DOMVendor := GetDOMVendor('MSXML');
  FDocument.Options := [doNodeAutoIndent];
end;

procedure TgSerializerXML.Deserialize(AObject: TgBase; const AString: String);
var
  HelperClass: TgSerializationHelperClass;
begin
  if Not Document.Active then
    Load(AString);
  HelperClass := G.SerializationHelpers(TgSerializerXML, AObject);
  HelperClass.Deserialize(AObject, Self);
end;

function TgSerializerXML.ExtractClassName(const AString: string): string;
begin
  Load(AString);
  Result := CurrentNode.Attributes['classname'];
end;

procedure TgSerializerXML.Load(const AString: String);
begin
  if (AString = '') or (AString = #$D#$A) then exit;
  Document.LoadFromXML(AString);
  FNodeStack.Push(Document.DocumentElement.ChildNodes[0]);
end;

class procedure TgSerializerXML.Register;
begin
  RegisterRuntimeClasses([
      THelperBase, THelperList, THelperIdentityObject, THelperIdentityList, THelperDictionary
    ]);

end;

function TgSerializerXML.Serialize(AObject: TgBase; ADefaultClass: TgBaseClass): String;
var
  HelperBaseClass: TgSerializationHelperClass;
begin
  FDocument.Active := True;
  TemporaryCurrentNode(Document.AddChild('xml'),procedure
    begin
      TemporaryCurrentNode(CurrentNode.AddChild(AObject.FriendlyClassName),procedure
      begin
        if ADefaultClass <> AObject.ClassType then
          CurrentNode.Attributes['classname'] := AObject.QualifiedClassName;
        HelperBaseClass := G.SerializationHelpers(TgSerializerXML, AObject);
        HelperBaseClass.Serialize(AObject, Self);
      end);
    end);
  Result := Document.XML.Text;
end;

{ TgSerializerXML.THelper }

class procedure TgSerializerXML.THelper<gBase>.Deserialize(AObject: gBase; ASerializer: TgSerializerXML; ARTTIProperty: TRTTIProperty = Nil);
var
  ChildNode: IXMLNode;
  Counter: Integer;
  ObjectProperty: TgBase;
  RTTIProperty: TRTTIProperty;
  HelperClass: TgSerializationHelperClass;
  AXMLNode: IXMLNode;
  ChildNodeName: String;
  ClassName: String;
begin
  AXMLNode := ASerializer.CurrentNode;
  ClassName := AXMLNode.Attributes['classname'];
  if (ClassName <> '') and Not SameText(ClassName, AObject.QualifiedClassName) then
    Raise EgParse.CreateFmt('Expected: %s, Parsed: %s', [AObject.QualifiedClassName, AXMLNode.Attributes['classname']]);
  for Counter := 0 to AXMLNode.ChildNodes.Count - 1 do
  begin
    ChildNode := AXMLNode.ChildNodes[Counter];
    ChildNodeName := ChildNode.NodeName;
    RTTIProperty := G.PropertyByName(AObject, ChildNodeName);
    if Not Assigned(RTTIProperty) then
      ASerializer.TemporaryCurrentNode(ChildNode,procedure
        begin
          DeserializeUnpublishedProperty(AObject, ASerializer, ChildNode.NodeName)
        end)
    Else if Not RTTIProperty.PropertyType.IsInstance then
    Begin
      if ChildNode.HasChildNodes then
        AObject.Values[ChildNode.NodeName] := ChildNode.ChildNodes.First.Text
      else
        AObject.Values[ChildNode.NodeName] := '';
    End
    Else
    Begin
      ObjectProperty := TgBase(RTTIProperty.GetValue(AObject.AsPointer).AsObject);
      If Assigned(ObjectProperty) And ObjectProperty.InheritsFrom(TgBase) And AObject.Owns(ObjectProperty) Then
      Begin
        HelperClass := G.SerializationHelpers(TgSerializerXML, ObjectProperty);
        ASerializer.TemporaryCurrentNode(ChildNode,procedure
          begin
            HelperClass.Deserialize(ObjectProperty, ASerializer);
          end);
      End;
    End;
  end;
end;

class procedure TgSerializerXML.THelper<gBase>.Serialize(AObject: gBase; ASerializer: TgSerializerXML; ARTTIProperty: TRTTIProperty = Nil);
var
  DoubleValue: Double;
  ObjectProperty: TgBase;
  RTTIProperty: TRTTIProperty;
  Value: Variant;
begin
  For RTTIProperty In G.SerializableProperties(AObject) Do
  Begin
    if RTTIProperty.PropertyType.IsInstance then
    Begin
      ObjectProperty := TgBase(AObject.Inspect(RTTIProperty));
      If Assigned(ObjectProperty) And ObjectProperty.InheritsFrom(TgBase) Then
        ASerializer.AddObjectProperty(RTTIProperty, ObjectProperty);
    End
    Else
    Begin
      if (RTTIProperty.PropertyType.TypeKind = tkFloat) then
      Begin
       DoubleValue := RTTIProperty.GetValue(AObject.AsPointer).AsVariant;
       If SameText(RTTIProperty.PropertyType.Name, 'TDate') then
         Value := FormatDateTime('m/d/yyyy', DoubleValue)
       Else if SameText(RTTIProperty.PropertyType.Name, 'TDateTime') then
         Value := FormatDateTime('m/d/yyyy hh:nn:ss', DoubleValue)
       Else
         Value := DoubleValue;
      End
      Else
        Value := AObject.Values[RTTIProperty.Name];
      ASerializer.AddValueProperty(RTTIProperty.Name, Value);
    End
  End;
end;

{ TgSerializerXML.THelperIdentityObject }

class procedure TgSerializerXML.THelperIdentityObject.Serialize(AObject: TgIdentityObject; ASerializer: TgSerializerXML; ARTTIProperty: TRTTIProperty = Nil);
begin
  if Not Assigned(ARTTIProperty) Or (Length(G.PropertyAttributes(G.TgPropertyAttributeClassKey.Create(ARTTIProperty, Composite))) > 0) then
    Inherited Serialize(AObject, ASerializer, ARTTIProperty)
  Else
    ASerializer.AddValueProperty('ID', AObject.ID);
end;

{ TgSerializerXML.THelperIdentityList }

class procedure TgSerializerXML.THelperIdentityList.Deserialize(
  AObject: TgIdentityList; ASerializer: TgSerializerXML;
  ARTTIProperty: TRTTIProperty);
begin
  inherited;

end;

class procedure TgSerializerXML.THelperIdentityList.DeserializeUnpublishedProperty(
  AObject: TgIdentityList; ASerializer: TgSerializerXML; const PropertyName: String);
var
  HelperClass: TgSerializationHelperClass;
  TempItemClass: TgObjectClass;
begin
  if SameText(PropertyName, AObject.ItemClass.FriendlyName) then
  Begin
    AObject.Add(ASerializer.CurrentNode.Attributes['classname']);
    HelperClass := G.SerializationHelpers(TgSerializerXML, AObject.Current);
    ASerializer.TemporaryCurrentNode(ASerializer.CurrentNode,procedure
      begin
        HelperClass.Deserialize(AObject.Current, ASerializer);
      end);
  End
  Else
    Inherited;
end;


class procedure TgSerializerXML.THelperIdentityList.Serialize(AObject: TgIdentityList; ASerializer: TgSerializerXML; ARTTIProperty: TRTTIProperty = Nil);
var
  ItemObject: TgBase;
  HelperClass: TgSerializationHelperClass;
begin
//  Inherited Serialize(AObject, ASerializer);
  if AObject.Count = 0 then exit;
  for ItemObject in AObject do
  Begin
    ASerializer.TemporaryCurrentNode(ASerializer.CurrentNode.AddChild(AObject.ItemClass.FriendlyName),procedure
      begin
        if AObject.ItemClass <> ItemObject.ClassType then
          ASerializer.CurrentNode.Attributes['classname'] := ItemObject.QualifiedClassName;
        HelperClass := G.SerializationHelpers(TgSerializerXML, ItemObject);
        HelperClass.Serialize(ItemObject, ASerializer);
      end);
  End;
end;

{ TgSerializerXML.THelperList }

class procedure TgSerializerXML.THelperList.DeserializeUnpublishedProperty(
  AObject: TgList; ASerializer: TgSerializerXML; const PropertyName: String);
var
  Counter: Integer;
  HelperClass: TgSerializationHelperClass;
  ItemClassName: String;
  ListItemNode: IXMLNode;
  ListNode: IXMLNode;
begin
  if SameText(PropertyName, 'List') then
  Begin
    ListNode := ASerializer.CurrentNode;
    for Counter := 0 to ListNode.ChildNodes.Count - 1 do
    Begin
      ListItemNode := ListNode.ChildNodes[Counter];
      ItemClassName := ListItemNode.Attributes['classname'];
      if ItemClassName <> '' then
        AObject.Add(G.ClassByName(ItemClassName))
      else
        AObject.Add;
      HelperClass := G.SerializationHelpers(TgSerializerXML, AObject.Current);
      ASerializer.TemporaryCurrentNode(ListItemNode,procedure
        begin
          HelperClass.Deserialize(AObject.Current, ASerializer);
        end);
    End;
  End
  Else
    Inherited;
end;

class procedure TgSerializerXML.THelperList.Serialize(AObject: TgList; ASerializer: TgSerializerXML; ARTTIProperty: TRTTIProperty = Nil);
begin
  Inherited Serialize(AObject, ASerializer);
  ASerializer.TemporaryCurrentNode(ASerializer.CurrentNode.AddChild('List'),procedure
    var
      ItemObject: TgBase;
      HelperClass: TgSerializationHelperClass;
    begin
      for ItemObject in AObject do
      Begin
        ASerializer.TemporaryCurrentNode(ASerializer.CurrentNode.AddChild(ItemObject.FriendlyClassName),procedure
          begin
            if AObject.ItemClass <> ItemObject.ClassType then
              ASerializer.CurrentNode.Attributes['classname'] := ItemObject.QualifiedClassName;
            HelperClass := G.SerializationHelpers(TgSerializerXML, ItemObject);
            HelperClass.Serialize(ItemObject, ASerializer);
          end);
      End;
    end);
end;

{ TgSerializerJSON.THelper<gBase> }


class procedure TgSerializerJSON.THelper<gBase>.Deserialize(AObject: gBase; ASerializer: TgSerializerJSON; ARTTIProperty: TRTTIProperty = Nil);
var
  JSONClassName: String;
  ObjectProperty: TgBase;
  Pair: TJSONPair;
  AJSONObject: TJSONObject;
  RTTIProperty: TRTTIProperty;
  HelperClass: TgSerializationHelperClass;
begin
  AJSONObject := ASerializer.CurrentNode;
  Pair := AJSONObject.Get('ClassName');
  JSONClassName := Pair.JsonValue.Value;
  if Not SameText(JSONClassName, AObject.QualifiedClassName) then
    Raise EgParse.CreateFmt('Expected: %s, Parsed: %s', [AObject.QualifiedClassName, JSONClassName]);
  for Pair in AJSONObject do
  begin
    if SameText(Pair.JsonString.Value, 'ClassName') then
      Continue;
    RTTIProperty := G.PropertyByName(AObject, Pair.JsonString.Value);
    if Not Assigned(RTTIProperty) then
      ASerializer.TemporaryCurrentNode(TJSONObject(Pair.JsonValue),procedure
        begin
          DeserializeUnpublishedProperty(AObject, ASerializer,Pair.JsonString.Value);
        end)
    Else if Not RTTIProperty.PropertyType.IsInstance then
      AObject.Values[Pair.JsonString.Value] := Pair.JsonValue.Value
    Else
    Begin
      ObjectProperty := TgBase(RTTIProperty.GetValue(AObject.AsPointer).AsObject);
      If Assigned(ObjectProperty) And ObjectProperty.InheritsFrom(TgBase) And AObject.Owns(ObjectProperty) Then
      Begin
        HelperClass := G.SerializationHelpers(TgSerializerJSON, ObjectProperty);
        if Assigned(HelperClass) then
          ASerializer.TemporaryCurrentNode(TJSONObject(Pair.JsonValue),procedure
            begin
              HelperClass.Deserialize(ObjectProperty, ASerializer);
            end);
      End;
    End;
  end;
end;

class procedure TgSerializerJSON.THelper<gBase>.Serialize(AObject: gBase; ASerializer: TgSerializerJSON; ARTTIProperty: TRTTIProperty = Nil);
var
  DoubleValue: Double;
  ObjectProperty: TgBase;
  RTTIProperty: TRTTIProperty;
  Value: Variant;
begin
  ASerializer.JSONObject.AddPair('ClassName', AObject.QualifiedClassName);
  For RTTIProperty In G.SerializableProperties(AObject) Do
  Begin
    If Not RTTIProperty.PropertyType.IsInstance Then
    Begin
      if (RTTIProperty.PropertyType.TypeKind = tkFloat) then
      Begin
       DoubleValue := RTTIProperty.GetValue(AObject.AsPointer).AsVariant;
       If SameText(RTTIProperty.PropertyType.Name, 'TDate') then
         Value := FormatDateTime('m/d/yyyy', DoubleValue)
       Else if SameText(RTTIProperty.PropertyType.Name, 'TDateTime') then
         Value := FormatDateTime('m/d/yyyy hh:nn:ss', DoubleValue)
       Else
         Value := DoubleValue;
      End
      Else
        Value := AObject.Values[RTTIProperty.Name];
      ASerializer.AddValueProperty(RTTIProperty.Name, Value);
    End
    Else
    Begin
      ObjectProperty := TgBase(AObject.Inspect(RTTIProperty));
      If Assigned(ObjectProperty) And ObjectProperty.InheritsFrom(TgBase) Then
        ASerializer.AddObjectProperty(RTTIProperty, ObjectProperty);
    End;
  End;
end;

{ TgSerializerJSON.THelperList }

class procedure TgSerializerJSON.THelperList.DeserializeUnpublishedProperty(
  AObject: TgList; ASerializer: TgSerializerJSON; const PropertyName: String);
var
  JSONValue: TJSONValue;
  HelperClass: TgSerializationHelperClass;
begin
  if SameText('List', PropertyName) then
  Begin
    If Not ASerializer.CurrentNode.InheritsFrom(TJSONArray) Then
      raise EgParse.CreateFmt('Expected: TJSONArray, Parsed: %s.', [ASerializer.CurrentNode.ClassName]);
    for JSONValue in TJSONArray(ASerializer.CurrentNode) Do
    Begin
      if Not JSONValue.InheritsFrom(TJSONObject) then
        raise EgParse.CreateFmt('Expected: TJSONObject, Parsed: %s', [JSONValue.ClassName]);
      AObject.Add;
      HelperClass := G.SerializationHelpers(TgSerializerJSON, AObject.Current);
      ASerializer.TemporaryCurrentNode(TJSONObject(JSONValue),procedure
        begin
          HelperClass.Deserialize(AObject.Current, ASerializer);
        end);
    End;
  End
  Else
    inherited;
end;

class procedure TgSerializerJSON.THelperList.Serialize(AObject: TgList; ASerializer: TgSerializerJSON; ARTTIProperty: TRTTIProperty = Nil);
var
  ItemObject: TgBase;
  ItemPointer: TObject;
  JSONArray: TJSONArray;
  ItemSerializer: TgSerializerJSON;
  HelperClass: THelperClass;
begin
  Inherited Serialize(AObject, ASerializer);
  JSONArray := TJSONArray.Create;
  try
    for ItemPointer in AObject do
    Begin
      ItemSerializer := TgSerializerJSON.Create;
      try
        ItemObject := TgBase(ItemPointer);
        HelperClass := G.SerializationHelpers(TgSerializerJSON, ItemObject);
        HelperClass.Serialize(ItemObject, ItemSerializer);
        JSONArray.AddElement(ItemSerializer.JSONObject);
        ItemSerializer.JSONObject := Nil;
      finally
        ItemSerializer.Free;
      end;
    End;
    ASerializer.JSONObject.AddPair('List', JSONArray);
    JSONArray := Nil;
  finally
    JSONArray.Free;
  end;
end;

{ TgSerializerJSON.THelperIdentityObject }

class procedure TgSerializerJSON.THelperIdentityObject.Serialize(AObject: TgIdentityObject; ASerializer: TgSerializerJSON; ARTTIProperty: TRTTIProperty = Nil);
begin
  if Not Assigned(ARTTIProperty) Or (Length(G.PropertyAttributes(G.TgPropertyAttributeClassKey.Create(ARTTIProperty, Composite))) > 0) then
    Inherited Serialize(AObject, ASerializer, ARTTIProperty)
  Else
    ASerializer.AddValueProperty('ID', AObject.ID);
end;

{ TgSerializerJSON.THelperIdentityList }

class procedure TgSerializerJSON.THelperIdentityList.DeserializeUnpublishedProperty(
  AObject: TgIdentityList; ASerializer: TgSerializerJSON;
  const PropertyName: String);
var
  JSONValue: TJSONValue;
  HelperClass: TgSerializationHelperClass;
begin
  if SameText('List', PropertyName) then
  Begin
    If Not ASerializer.CurrentNode.InheritsFrom(TJSONArray) Then
      raise EgParse.CreateFmt('Expected: TJSONArray, Parsed: %s.', [ASerializer.CurrentNode.ClassName]);
    for JSONValue in TJSONArray(ASerializer.CurrentNode) Do
    Begin
      if Not JSONValue.InheritsFrom(TJSONObject) then
        raise EgParse.CreateFmt('Expected: TJSONObject, Parsed: %s', [JSONValue.ClassName]);
      AObject.Add;
      HelperClass := G.SerializationHelpers(TgSerializerJSON, AObject.Current);
      ASerializer.TemporaryCurrentNode(TJSONObject(JSONValue),procedure
        begin
          HelperClass.Deserialize(AObject.Current, ASerializer);
        end);
    End;
  End
  Else
    inherited;

end;

class procedure TgSerializerJSON.THelperIdentityList.Serialize(AObject: TgIdentityList; ASerializer: TgSerializerJSON; ARTTIProperty: TRTTIProperty = Nil);
begin
  if Not Assigned(ARTTIProperty) Or (Length(G.PropertyAttributes(G.TgPropertyAttributeClassKey.Create(ARTTIProperty, Composite))) > 0) then
    Inherited Serialize(AObject, ASerializer, ARTTIProperty);
end;

{ TgSerializerJSON }

procedure TgSerializerJSON.AddObjectProperty(ARTTIProperty: TRTTIProperty; AObject: TgBase);
var
  HelperClass: TgSerializationHelperClass;
  Serializer: TgSerializerJSON;
begin
  Serializer := TgSerializerJSON.Create;
  Try
    HelperClass := G.SerializationHelpers(TgSerializerJSON, AObject);
    HelperClass.Serialize(AObject, Serializer, ARTTIProperty);
    JSONObject.AddPair(ARTTIProperty.Name, Serializer.JSONObject);
  Finally
    Serializer.JSONObject := Nil;
    Serializer.Free;
  End;
end;

procedure TgSerializerJSON.AddValueProperty(const AName: string; AValue: Variant);
begin
  JSONObject.AddPair(AName, AValue);
end;

constructor TgSerializerJSON.Create;
begin
  inherited Create;
  FJSONObject := TJSONObject.Create();
end;

procedure TgSerializerJSON.Deserialize(AObject: TgBase; const AString: string);
var
  HelperClass: TgSerializationHelperClass;
begin
  if FJSONObject.Size = 0 then
    Load(AString);
  HelperClass := G.SerializationHelpers(TgSerializerJSON, AObject);
  TemporaryCurrentNode(JSONObject,procedure
    begin
      HelperClass.Deserialize(AObject, Self);
    end);
end;

destructor TgSerializerJSON.Destroy;
begin
  FreeAndNil(FJSONObject);
  inherited Destroy;
end;

function TgSerializerJSON.ExtractClassName(const AString: string): string;
begin
  Load(AString);
  Result := JSONObject.Get('ClassName').JsonValue.Value;
end;

procedure TgSerializerJSON.Load(const AString: string);
begin
  FreeAndNil(FJSONObject);
  JSONObject := TJSONObject.ParseJSONValue(AString) As TJSONObject;
end;

class procedure TgSerializerJSON.Register;
begin
  RegisterRuntimeClasses([THelperBase,THelperList.BaseClass
    , THelperIdentityObject, THelperIdentityList]);
end;

function TgSerializerJSON.Serialize(AObject: TgBase; ADefaultClass: TgBaseClass): String;
var
  HelperClass: TgSerializationHelperClass;
begin
  HelperClass := G.SerializationHelpers(TgSerializerJSON, AObject);
  HelperClass.Serialize(AObject, Self);
  Result := JSONObject.ToString;
end;


{ TgSerializationHelper<gBase, gSerializer> }

class function TgSerializationHelper<gBase,gSerializer>.SerializerClass: TgSerializerClass;
begin
  Result := gSerializer;
end;

class function TgSerializationHelper<gBase, gSerializer>.BaseClass: TgBaseClass;
begin
  Result := gBase;
end;

class procedure TgSerializationHelper<gBase,gSerializer>.Serialize(
  AObject: TgBase; ASerializer: TgSerializer; ARTTIProperty: TRTTIProperty);
var
  Serializer: gSerializer;
  Object_: gBase;
begin
  Serializer := gSerializer(ASerializer);
  Object_ := gBase(AObject);
  Serialize(Object_, Serializer , ARTTIProperty);
end;


class procedure TgSerializationHelper<gBase,gSerializer>.Deserialize(AObject: TgBase;
  ASerializer: TgSerializer; ARTTIProperty: TRTTIProperty = Nil);
var
  Serializer: gSerializer;
  Object_: gBase;
begin
  Serializer := gSerializer(ASerializer);
  Object_ := gBase(AObject);
  Deserialize(Object_,Serializer,ARTTIProperty);
end;


class procedure TgSerializationHelper<gBase,gSerializer>.DeserializeUnpublishedProperty(
  AObject: gBase; ASerializer: gSerializer; const PropertyName: String);
begin
  raise E.CreateFmt('Attempt to deserialize unknown property %s for %s.', [PropertyName, ClassName]);
end;

class procedure TgSerializationHelper<gBase,gSerializer>.DeserializeUnpublishedProperty(
  AObject: TgBase; ASerializer: TgSerializer; const PropertyName: String);
var
  Serializer: gSerializer;
  Object_: gBase;
begin
  Serializer := gSerializer(ASerializer);
  Object_ := gBase(AObject);
  DeserializeUnpublishedProperty(Object_, Serializer, PropertyName);
end;

{ TgList<T> }

constructor TgList<T>.Create(AOwner: TgBase = nil);
begin
  Inherited Create(AOwner);
  ItemClass := T;
end;

class function TgList<T>.AddAttributes(ARTTIProperty: TRttiProperty): System.TArray<System.TCustomAttribute>;
begin
  Result := inherited AddAttributes(ARTTIProperty);
  if SameText(ARTTIProperty.Name, 'Current') then
  Begin
    SetLength(Result, Length(Result) + 3);
    Result[Length(Result) - 3] := NotAutoCreate.Create;
    Result[Length(Result) - 2] := NotSerializable.Create;
    Result[Length(Result) - 1] := NotAssignable.Create;
  End;
end;

function TgList<T>.GetCurrent: T;
Begin
  Result := T(Inherited GetCurrent);
End;

function TgList<T>.GetItems(AIndex : Integer): T;
Begin
  Result := T(Inherited GetItems(AIndex));
End;

procedure TgList<T>.SetItems(AIndex : Integer; const AValue: T);
Begin
  Inherited SetItems(AIndex, AValue);
End;

class function TgList<T>._ItemClass: TgBaseClass;
begin
  Result := T;
end;

function TgList<T>.GetEnumerator: TgEnumerator;
Begin
  Result.Init(Self);
End;

procedure TgList<T>.SetItemClass(const Value: TgBaseClass);
begin
  if Assigned(Value) And  Not Value.InheritsFrom(T) then
    raise EgList.CreateFmt('Attempt to set an item class of %s with a non-descendant value of %s.', [T.ClassName, Value.ClassName]);
  Inherited SetItemClass(Value);
end;

{ TgList }

constructor TgList.Create(AOwner: TgBase = Nil);
Begin
  Inherited Create(AOwner);
  FList := TObjectList<TgBase>.Create;
  FCurrentIndex := -1;
End;

destructor TgList.Destroy;
Begin
  FOrderByList.Free;
  FList.Free;
  Inherited;
End;

procedure TgList.Add;
Begin
  Add(ItemClass);
End;

procedure TgList.Add(AItemClass: TgBaseClass);
begin
  FCurrentIndex := FList.Add(AItemClass.Create(Self));
end;

procedure TgList.Add(const AItemClassName: String);
begin
  if AItemClassName <> '' then
    Add(G.ClassByName(AItemClassName))
  else
    Add;
end;

procedure TgList.Assign(ASource: TgBase);
var
  Item: TgBase;
  Counter: Integer;
  SourceList: TgList;
begin
  Clear;
  inherited Assign(ASource);
  SourceList := TgList(ASource);
  for Counter := 0 to SourceList.Count - 1 do
  begin
    // The itemclass may vary from item to item.
    Item := SourceList.Items[Counter];
    ItemClass := TgBaseClass(Item.ClassType);
    Add;
    Items[CurrentIndex].Assign(Item);
  end;
  CurrentIndex := SourceList.CurrentIndex
end;

procedure TgList.Clear;
begin
  FList.Clear;
  FCurrentIndex := -1;
end;

procedure TgList.Delete;
Begin
  if CurrentIndex > -1 then
    FList.Delete(CurrentIndex)
  Else
    raise EgList.Create('There is no item to delete.');
End;

function TgList.DoGetObjects(const APath: string; out AValue: TgBase): Boolean;
var
  Position: Integer;
begin
  Result := inherited;
  If Not Result Then
  Begin
    If (Length(APath) > 0) And (APath[1] = '[') Then
    Begin
      Position := Pos(']', APath);
      If Position > 0 Then
      Begin
        IndexString := Trim(Copy(APath, 2, Position - 2));
        Result := True;
        AValue := Current;
      End;
    End;
  End;

end;

function TgList.DoGetValues(Const APath : String; Out AValue : Variant): Boolean;
Var
  Position : Integer;
Begin
  Result := Inherited DoGetValues(APath, AValue);
  If Not Result Then
  Begin
    If (Length(APath) > 0) And (APath[1] = '[') Then
    Begin
      Position := Pos(']', APath);
      If Position > 0 Then
      Begin
        IndexString := Trim(Copy(APath, 2, Position - 2));
        Result := True;
        AValue := Current.Values[Copy(APath, Position + 2, MaxInt)];
      End;
    End;
  End;
End;

function TgList.DoSetValues(Const APath : String; AValue : Variant): Boolean;
Var
  Position : Integer;
Begin
  Result := Inherited DoSetValues(APath, AValue);
  If Not Result Then
  Begin
    If (Length(APath) > 0) And (APath[1] = '[') Then
    Begin
      Position := Pos(']', APath);
      If Position > 0 Then
      Begin
        IndexString := Trim(Copy(APath, 2, Position - 2));
        Result := True;
        Current.Values[Copy(APath, Position + 2, MaxInt)] := AValue;
      End;
    End;
  End;
End;

procedure TgList.Filter;
begin
  If Not IsFiltered And ( Where > '' ) Then
  Begin
    Last;
    while Not BOL do
    Begin
      if Not Eval(Where, Current) then
        Delete
      else
        Previous;
    End;
    IsFiltered := True;
  End;
end;

procedure TgList.First;
Begin
  FCurrentIndex := -1;
End;

function TgList.GetBOL: Boolean;
Begin
  Result := Min(FCurrentIndex, FList.Count - 1) = - 1;
End;

function TgList.GetCanAdd: Boolean;
Begin
  Result := True;
End;

function TgList.GetCanNext: Boolean;
Begin
  Result := (Count > 1) And InRange(FCurrentIndex, - 1, Count - 2);
End;

function TgList.GetCanPrevious: Boolean;
Begin
  Result := (Count > 1) And (FCurrentIndex > 0);
End;

function TgList.GetCount: Integer;
Begin
  Result := FList.Count;
End;

function TgList.GetCurrent: TgBase;
Begin
  if CurrentIndex = -1 then
    raise EgList.CreateFmt('Attempted to get an item from an empty %s FList.', [ClassName]);
  Result := FList[CurrentIndex];
End;

function TgList.GetCurrentIndex: Integer;
Begin
  If FList.Count > 0 Then
    Result := EnsureRange(FCurrentIndex, 0, FList.Count - 1)
  Else
    Result := - 1;
End;

function TgList.GetEnumerator: TgEnumerator;
Begin
  Result.Init(Self);
End;

function TgList.GetEOL: Boolean;
Begin
  Result := Max(FCurrentIndex, 0) = FList.Count;
End;

function TgList.GetHasItems: Boolean;
begin
  Result := Count > 0;
end;

function TgList.GetIsFiltered: Boolean;
begin
  Result := osFiltered In FStates;
end;

function TgList.GetIsOrdered: Boolean;
begin
  Result := osOrdered In FStates;
end;

function TgList.GetItemClass: TgBaseClass;
begin
  Result := FItemClass;
end;

function TgList.GetItems(AIndex : Integer): TgBase;
Begin
  if InRange(AIndex, 0, FList.Count - 1) then begin
    CurrentIndex := AIndex;
    Result := FList[AIndex];
  end
  Else
    Raise EgList.CreateFmt('Failed to get the item at index %d, because the valid range is between 0 and %d.', [AIndex, FList.Count - 1]);
End;

function TgList.GetOrderByList: TObjectList<TgOrderByItem>;
begin
  If Not Assigned( FOrderByList ) Then
    FOrderByList := TObjectList<TgOrderByItem>.Create;
  Result := FOrderByList;
end;

function TgList.GetIndexString: String;
begin
  Result := IntToStr(CurrentIndex);
end;

function TgList.GetObjectChildPathName(AChild: TgBase = nil): string;
begin
  if AChild = Current then
    Result := Format('%sCurrent',[inherited,CurrentIndex])
  else
    Result := Format('%s[%d]',[inherited,CurrentIndex]);
end;

procedure TgList.Last;
Begin
  FCurrentIndex := FList.Count;
End;

procedure TgList.Next;
Begin
  If (FList.Count > 0) And (FCurrentIndex < FList.Count) Then
    FCurrentIndex := CurrentIndex + 1
  Else
    Raise EgList.Create('Failed attempt to move past end of FList.');
End;

procedure TgList.Previous;
Begin
  If (FList.Count > 0) And (FCurrentIndex > -1) Then
    FCurrentIndex := CurrentIndex - 1
  Else
    Raise EgList.Create('Failed attempt to move past end of FList.');
End;

function TgList.RestKeyToIndex(const Key: String; out Index: Integer): boolean;
begin
  Result := TryStrToInt(Key,Index);
end;

procedure TgList.SetCurrentIndex(const AIndex: Integer);
Begin
  if FCurrentIndex = AIndex then exit;
  If (FList.Count > 0) And InRange(AIndex, 0, FList.Count - 1) Then
    FCurrentIndex := AIndex
  Else
    Raise EgList.CreateFmt('Failed to set CurrentIndex to %d, because the valid range is between 0 and %d.', [AIndex, FList.Count - 1]);
End;

procedure TgList.SetIndexString(const AValue: String);
var
  Index: Integer;
begin
  if Not TryStrToInt(AValue, Index) then
    raise TgBase.EgValue.CreateFmt('Cannot set the index string to %s, because it is not an integer.', [AValue]);
  CurrentIndex := Index;
end;

procedure TgList.SetIsFiltered(const AValue: Boolean);
begin
  If AValue Then
    Include(FStates, osFiltered)
  Else
    Exclude(FStates, osFiltered);
  FCurrentIndex := -1;
end;

procedure TgList.SetIsOrdered(const AValue: Boolean);
begin
  If AValue Then
    Include(FStates, osOrdered)
  Else
    Exclude(FStates, osOrdered);
end;

procedure TgList.SetItemClass(const Value: TgBaseClass);
begin
  if Not Assigned(Value) then
    raise EgList.Create('Attempted to set a NIL item class.');
  FItemClass := Value;
end;

procedure TgList.SetItems(AIndex : Integer; const AValue: TgBase);
Begin
  if InRange(AIndex, 0, FList.Count - 1) then
    FList[AIndex] := AValue
  Else
    Raise EgList.CreateFmt('Failed to set the item at index %d, because the valid range is between 0 and %d.', [AIndex, FList.Count - 1]);
End;

procedure TgList.SetOrderBy(const AValue: String);
var
  StringList: TStringList;
  ItemText: String;
  Item: TgOrderByItem;
begin
  FOrderBy := AValue;
  IsOrdered := False;
  OrderByList.Clear;
  StringList := TStringList.Create;
  try
    StringList.StrictDelimiter := True;
    StringList.CommaText := AValue;
    For ItemText In StringList Do
    Begin
      Item := TgOrderByItem.Create( ItemText );
      OrderByList.Add( Item );
    End;
  finally
    StringList.Free;
  end;
end;

procedure TgList.SetWhere(const AValue: String);
begin
  FWhere := AValue;
end;

procedure TgList.Sort;
var
  Comparer: TgComparer;
begin
  if (OrderBy > '') and (Count > 0) then
  Begin
//    EnsureOrderByDefault;
    Comparer := TgComparer.Create(OrderByList);
    try
      FList.Sort(Comparer);
    finally
      Comparer.Free;
    end;
    IsOrdered := True;
  End;
end;

function TgList.DoUseRestPath(const Path: string; var TemplateName: string; out gBase: TgBase; const Delim: char = '/'): Boolean;
var
  Head: String;
  Tail: String;
  Index: Integer;
begin
  if Path = '' then  Exit(inherited);
  SplitPath(Path,Head,Tail,Delim);
  if not RestKeyToIndex(Head,Index) then Exit(False);
  CurrentIndex := Index;
  if Tail <> '' then
    Result := Current.DoUseRestPath(Tail,TemplateName,gBase,Delim)
  else begin
    gBase := Current;
    TemplateName := TemplateName+'Form';
    Result := True;
  end;



end;

class function TgList._ItemClass: TgBaseClass;
begin
  Result := nil
end;

{ TgList.TgEnumerator }

procedure TgList.TgEnumerator.Init(AList: TgList);
begin
  FList := AList;
  FCurrentIndex := -1;
  FList.First;
end;

function TgList.TgEnumerator.GetCurrent: TgBase;
begin
  FList.CurrentIndex := FCurrentIndex;
  Result := FList.Current;
end;

function TgList.TgEnumerator.MoveNext: Boolean;
begin
  If FList.Count = 0 Then
    Exit(False);
  if FCurrentIndex > -1 then
  Begin
    FList.CurrentIndex := FCurrentIndex;
    FList.Next;
  End;
  Inc(FCurrentIndex);
  Result := Not FList.EOL;
end;

{ TgBaseClassComparer }

function G.TgBaseClassComparer.Compare(const Left, Right: TRTTIType): Integer;

  function Level(ARTTIType : TRTTIType) : Integer;
  var
    BaseClass : TClass;
  begin
    Result := 0;
    BaseClass := ARTTIType.AsInstance.MetaclassType;
    while BaseClass <> TgBase do
    Begin
      Inc(Result);
      BaseClass := BaseClass.ClassParent;
    End;
  end;

begin
  if Left = Right then
    Result := 0
  Else if Level(Left) > Level(Right) then
    Result := 1
  Else if Level(Right) > Level(Left) then
    Result := -1
  Else
    Result := CompareText(Left.AsInstance.MetaclassType.ClassName, Right.AsInstance.MetaclassType.ClassName)
end;

{  TgBaseExpressionEvaluator }

Constructor TgBaseExpressionEvaluator.Create(AModel : TgBase);
Begin
  Assert(Assigned(AModel), 'No model assigned');
  Inherited Create;
  FModel := AModel;
End;

Function TgBaseExpressionEvaluator.GetValue(Const AVariableName : String) : Variant;
Begin
  Result := FModel[AVariableName];
End;

{ TgList.TgOrderByItem }

constructor TgList.TgOrderByItem.Create(const AItemText: String);
var
  PosOfSpace: Integer;
  Direction: String;
  TrimmedItemText: String;
begin
  TrimmedItemText := Trim( AItemText );
  PosOfSpace := Pos( ' ', TrimmedItemText );
  If PosOfSpace > 0 Then
  Begin
    PropertyName := Trim( Copy( TrimmedItemText, 1, PosOfSpace ) );
    Direction := Trim( Copy( TrimmedItemText, PosOfSpace, MaxInt ) );
    If SameText( Direction, 'DESC' ) Then
      Descending := True
    Else If SameText( Direction, 'ASC' ) Then
      Descending := False
    Else
      Raise EgOrderByItem.CreateFmt( '''%s'' is an invalid Order By direction.', [Direction] );
  End
  Else
  Begin
    PropertyName := TrimmedItemText;
    Descending := False;
  End;
end;

function TgList.TgComparer.Compare(const Left, Right: TgBase): Integer;
Var
  Value1 : Variant;
  Value2 : Variant;
  PropertyName: String;
  OrderByItem: TgOrderByItem;
Begin
  Result := 0;
  If FOrderByList.Count > 0 Then
  Begin
    For OrderByItem In FOrderByList Do
    Begin
      PropertyName := OrderByItem.PropertyName;
      Value1 := Left[PropertyName];
      Value2 := Right[PropertyName];
      If VarIsType(Value1, varString) Then
      Begin
        Value1 := UpperCase(Value1);
        Value2 := UpperCase(Value2);
      End;
      If Value1 <> Value2 Then
      Begin
        If Value1 < Value2 Then
          Result := -1
        Else If Value1 > Value2 Then
          Result := 1;
        If OrderByItem.Descending Then
          Result := Result * -1;
        Exit;
      End;
    End;
  End;
end;

constructor TgList.TgComparer.Create(AOrderByList: TObjectList<TgOrderByItem>);
begin
  inherited Create;
  FOrderByList := AOrderByList;
end;

{ TgList<T>.TgEnumerator }

function TgList<T>.TgEnumerator.GetCurrent: T;
begin
  FList.CurrentIndex := FCurrentIndex;
  Result := FList.Current;
end;

procedure TgList<T>.TgEnumerator.Init(AList: TgList<T>);
begin
  FList := AList;
  FList.First;
  FCurrentIndex := -1;
end;

function TgList<T>.TgEnumerator.MoveNext: Boolean;
begin
  If FList.Count = 0 Then
    Exit(False);
  if FCurrentIndex > -1 then
  Begin
    FList.CurrentIndex := FCurrentIndex;
    FList.Next;
  End;
  Inc(FCurrentIndex);
  Result := Not FList.EOL;
end;

constructor TgObject.Create(AOwner: TgBase = nil);
begin
  inherited;
  PopulateDefaultValues;
end;

destructor TgObject.Destroy;
var
  ObjectProperty: TgObject;
  RTTIProperty: TRTTIProperty;
begin
  for RTTIProperty in G.AutoCreateProperties(Self) do
  Begin
    ObjectProperty := TgObject(RTTIProperty.GetValue(Self).AsObject);
    if Owns(ObjectProperty) then
      ObjectProperty.Free;
  End;
  if Assigned(FOriginalValues) then
    FreeAndNil(FOriginalValues);
  Inherited Destroy;
end;

function TgObject.AllValidationErrors: String;
var
  ObjectProperty: TgObject;
  StringList: TStringList;
  RTTIProperty: TRTTIProperty;
begin
  StringList := TStringList.Create;
  try
    ValidationErrors.PopulateList(StringList);
    for RTTIProperty in G.CompositeProperties(Self) do
    begin
      ObjectProperty := TgObject(Inspect(RTTIProperty));
      if Assigned(ObjectProperty) And ObjectProperty.InheritsFrom(TgObject) then
        ObjectProperty.ValidationErrors.PopulateList(StringList);
    end;
    Result := StringList.Text;
  finally
    StringList.Free;
  end;
end;

class function TgObject.DisplayPropertyNames: TArray<String>;
var
  RTTIProperty: TRTTIProperty;
begin
  for RTTIProperty in G.VisibleProperties(Self) do
  begin
    if Not RTTIProperty.PropertyType.IsInstance then
    Begin
      SetLength(Result, 1);
      Result[0] := RTTIProperty.Name;
    End;
  end;
end;

function TgObject.GetDisplayName: String;
var
  PropertyName: String;
begin
  Result := '';
  for PropertyName in DisplayPropertyNames do
    Result := Result + Values[PropertyName] + ', ';
  if Result > '' then
    SetLength(Result,  Length(Result) - 2);
end;

function TgObject.GetIsValid: Boolean;
var
  ObjectProperty: TgObject;
  RTTIProperty: TRTTIProperty;
begin
  ValidationErrors.Clear;
  GetIsValidInternal;
  Result := Not ValidationErrors.HasItems;
  for RTTIProperty in G.CompositeProperties(Self) do
  Begin
    ObjectProperty := TgObject(Inspect(RTTIProperty));
    if Assigned(ObjectProperty) And ObjectProperty.InheritsFrom(TgObject) And Owns(ObjectProperty) And Not ObjectProperty.IsValid then
      Exit(False);
  End;
end;

procedure TgObject.GetIsValidInternal;
var
  PropertyValidationAttribute: G.TgPropertyValidationAttribute;
begin
  for PropertyValidationAttribute in G.PropertyValidationAttributes(Self) do
    PropertyValidationAttribute.Execute(Self);
end;

function TgObject.GetOriginalValues: TgOriginalValues;
begin
  if Not IsInspecting And Not IsOriginalValues And Not Assigned(FOriginalValues) then
  Begin
    IsCreatingOriginalValues := True;
    FOriginalValues := TgOriginalValues.Create(Self);
    IsCreatingOriginalValues := False;
  End;
  Result := FOriginalValues;
end;

function TgObject.GetValidationErrors: TgValidationErrors;
begin
  if Not IsInspecting And Not Assigned(FValidationErrors) then
    FValidationErrors := TgValidationErrors.Create;
  Result := FValidationErrors;
end;

function TgObject.HasValidationErrors: Boolean;
var
  RTTIProperty: TRTTIProperty;
  ObjectProperty : TgObject;
begin
  Result := ValidationErrors.Count > 0;
  if Not Result then
  Begin
    for RTTIProperty in G.CompositeProperties(Self) do
    begin
      ObjectProperty := TgObject(Inspect(RTTIProperty));
      if Assigned(ObjectProperty) And ObjectProperty.InheritsFrom(TgObject) then
      Begin
        Result := ObjectProperty.HasValidationErrors;
        if Result then
          Exit;
      End;
    end;
  End;
end;

procedure TgObject.InitializeOriginalValues;
begin
  if Assigned(OriginalValues) then
    OriginalValues.Load;
end;

procedure TgObject.PopulateDefaultValues;
Var
  Attribute : TCustomAttribute;
Begin
  For Attribute In G.Attributes(Self, DefaultValue) Do
    DefaultValue(Attribute).Execute(Self);
End;

procedure TgObject.TgValidationErrors.Clear;
begin
  FDictionary.Clear;
end;

{ TgObject.TgValidationErrors }
constructor TgObject.TgValidationErrors.Create(AOwner: TgBase = Nil);
begin
  inherited Create(AOwner);
  FDictionary := TDictionary<String, String>.Create();
end;

destructor TgObject.TgValidationErrors.Destroy;
begin
  FreeAndNil(FDictionary);
  inherited Destroy;
end;

function TgObject.TgValidationErrors.DoGetValues(const APath: string; out AValue: Variant): Boolean;
var
  TempString: String;
begin
  Result := inherited DoGetValues(APath, AValue);
  if Not Result then
  Begin
    If FDictionary.TryGetValue(APath, TempString) Then
      AValue := TempString
    else
      AValue := '';
    Result := True;
  End;
end;

function TgObject.TgValidationErrors.DoSetValues(const APath: string; AValue: Variant): Boolean;
var
  TempString: String;
begin
  Result := inherited DoSetValues(APath, AValue);
  if Not Result then
  Begin
    TempString := AValue;
    FDictionary.AddOrSetValue(APath, TempString);
    Result := True;
  End;
end;

function TgObject.TgValidationErrors.GetCount: Integer;
begin
  Result := FDictionary.Count;
end;

function TgObject.TgValidationErrors.GetHasItems: Boolean;
begin
  Result := Count > 0;
end;

procedure TgObject.TgValidationErrors.PopulateList(AStringList: TStrings);
var
  Pair: TPair<String, String>;
begin
  for Pair in FDictionary do
    AStringList.Add(Pair.Key + ': ' + Pair.Value);
end;

{ DisplayPropertyNames }

constructor DisplayPropertyNames.Create(AValue: TArray<String>);
begin
  inherited Create;
  FValue := AValue;
end;

{ Required }

constructor Required.Create;
begin
  inherited Create;
  FEnabled := True;
end;

procedure Required.Execute(AObject: TgObject; ARTTIProperty: TRTTIProperty);
var
  IdentityObject: TgIdentityObject;
  RaiseException: Boolean;
  Value: Variant;
  LookupObject : TgIdentityObject;
begin
  if Not Enabled Then
    Exit;
  RaiseException := False;
  If ARTTIProperty.PropertyType.IsInstance then
  begin
    IdentityObject := TgIdentityObject(AObject.Inspect(ARTTIProperty));
    if Not Assigned(IdentityObject) then
      RaiseException := True
    Else
    Begin
      if IdentityObject.InheritsFrom(TgIdentityObject) Then
      Begin
        if Not IdentityObject.HasIdentity Then
          RaiseException := True
        Else If Not IdentityObject.IsLoaded then
        Begin
          if AObject.Owns(IdentityObject) then
          Begin
            LookupObject := TgIdentityObjectClass(IdentityObject.ClassType).Create(IdentityObject.Owner);
            try
              LookupObject.ID := IdentityObject.ID;
              If Not LookupObject.Load Then
                RaiseException := True;
            finally
              LookupObject.Free;
            end;
          End;
        End;
      End;
    End;
  end
  Else
  Begin
    Value := AObject[ARTTIProperty.Name];
    case VarType(Value) of
      varSmallint, varInteger, varShortInt, varByte, varWord, varLongWord, varInt64, varUInt64, varSingle, varDouble, varCurrency, varDate :
        if Value = 0 then RaiseException := True;
      varUString :
        if Value = '' then RaiseException := True;
    end;
  End;
  if RaiseException then
    AObject.ValidationErrors[ARTTIProperty.Name] := Format('%s is Required.', [ARTTIProperty.Name]);
end;

{ G.TgPropertyValidationAttribute }

procedure G.TgPropertyValidationAttribute.Execute(AObject: TgObject);
begin
  ValidationAttribute.Execute(AObject, RTTIProperty);
end;

{ NotRequired }

constructor NotRequired.Create;
begin
  inherited Create;
  FEnabled := False;
end;

{ TgPropertyAttributeClassKey }

constructor G.TgPropertyAttributeClassKey.Create(ARTTIProperty: TRttiProperty; AAttributeClass: TCustomAttributeClass);
begin
  RTTIProperty := ARTTIProperty;
  AttributeClass := AAttributeClass;
end;

{ TgIdentityObject<T> }

class constructor TgIdentityObject<T>.Create;
begin
  T_TypeInfo := TypeInfo(T);
end;

function TgIdentityObject<T>.GetID: T;
var
  Value: TValue;
begin
//  Result := Inherited GetID;
{$IFDEF DEBUG}
  try
{$ENDIF}
    Value := TValue.FromVariant(inherited ID);
    Result := Value.AsType<T>;
{$IFDEF DEBUG}
  except
    raise;
  end;
{$ENDIF}

end;

procedure TgIdentityObject<T>.SetID(const AValue: T);
begin
//  Inherited SetID(AValue);
  inherited ID := TValue.From<T>(AValue).AsVariant;
end;

constructor TgIdentityObject.Create(AOwner: TgBase = nil);
var
  TempOwner: TgIdentityObject;
begin
  // When a TgIdentityObject begins to create its OriginalValues
  // it sets IsCreatingOriginalValues, then passes itself as the owner.
  // This constructor checks for the owner's IsCreatingOriginalValues and, if true,
  // sets IsOriginalValues for the current object and resets its owner
  // to the main object

  TempOwner := TgIdentityObject(AOwner);
  If Assigned(TempOwner) And TempOwner.InheritsFrom(TgIdentityObject) And TempOwner.IsCreatingOriginalValues Then
  Begin
    TempOwner := TgIdentityObject(TempOwner.Owner);
    IsOriginalValues := True;
  End;
  inherited Create(TempOwner);
end;

{ TgIdentityObject }

procedure TgIdentityObject.Assign(ASource: TgBase);
begin
  inherited Assign(ASource);
  if ASource is TgIdentityObject then
    ID := TgIdentityObject(ASource).ID;


  IsLoaded := TgIdentityObject(ASource).IsLoaded;
end;

procedure TgIdentityObject.Commit;
begin
  PersistenceManager.Commit(Self);
end;

procedure TgIdentityObject.Delete;
begin
  IsDeleting := True;
  try
    If CanDelete Then
      DoDelete
    Else
      Raise E.CreateFmt('Cannot DoDelete ''%s'' object.', [ClassName]);
  finally
    IsDeleting := False;
  end;
end;

procedure TgIdentityObject.DoDelete;
var
  IdentityList: TgIdentityList;
  IdentityObjectClassProperty: G.TgIdentityObjectClassProperty;
  IDString: String;
begin

  //Delete the objects with references
  for IdentityObjectClassProperty in G.References(Self) do
  begin
    IdentityList := TgIdentityList.Create;
    try
      IdentityList.ItemClass := IdentityObjectClassProperty.IdentityObjectClass;
      IDString := ID;
      IdentityList.Where := Format('%s.ID = ''%s''', [IdentityObjectClassProperty.RTTIProperty.Name, IDString]);
      IdentityList.Last;
      while Not IdentityList.BOL do
        IdentityList.Delete;
    finally
      IdentityList.Free;
    end;
  end;

  PersistenceManager.DeleteObject(Self);
  RemoveIdentity;
end;

procedure TgIdentityObject.DoLoad;
begin
  PersistenceManager.LoadObject(Self);
end;

procedure TgIdentityObject.DoSave;
var
  IdentityList: TgIdentityList;
  RTTIProperty: TRTTIProperty;
begin
  PersistenceManager.SaveObject(Self);
  IsLoaded := True;
  for RTTIProperty in G.IdentityListProperties(Self) do
  Begin
    IdentityList := TgIdentityList(Inspect(RTTIProperty));
    if Assigned(IdentityList) then
      IdentityList.Save;
  End;
end;

function TgIdentityObject.GetCanDelete: Boolean;
var
  IdentityObjectClassProperty: G.TgIdentityObjectClassProperty;
  IdentityList: TgIdentityList;
  IDString : String;
  IdentityObject: TgIdentityObject;
begin
  // Delete is impossible without identity
  Result := HasIdentity;
  if Result then
  Begin
    // If Delete is possible, but the CascadeDelete Attribute is not present...
    if (Length(G.Attributes(Self, CascadeDelete)) = 0) then
    Begin
      // Check all references
      for IdentityObjectClassProperty in G.References(Self) do
      begin
        IdentityList := TgIdentityList.Create;
        try
          IdentityList.ItemClass := IdentityObjectClassProperty.IdentityObjectClass;
          IDString := ID;
          IdentityList.Where := Format('%s.ID = ''%s''', [IdentityObjectClassProperty.RTTIProperty.Name, IDString]);
          // Return False if one is found
          Result := Not IdentityList.HasItems;
        finally
          IdentityList.Free;
        end;
      end;
    End
    Else
    // If the CascadeDelete Attribute is present...
    Begin
      // Check all references
      for IdentityObjectClassProperty in G.References(Self) do
      begin
        IdentityList := TgIdentityList.Create;
        try
          IdentityList.ItemClass := IdentityObjectClassProperty.IdentityObjectClass;
          IDString := ID;
          IdentityList.Where := Format('%s.ID = ''%s''', [IdentityObjectClassProperty.RTTIProperty.Name, IDString]);
          for IdentityObject in IdentityList do
          begin
            Result := IdentityObject.CanDelete;
            if Not Result then
              Exit;
          end;
        finally
          IdentityList.Free;
        end;
      end;
    End;
  End;
end;

function TgIdentityObject.GetCanSave: Boolean;
begin
  Result := Not HasIdentity or IsModified;
  If Result And Not IsValid Then
    Raise EgValidation.Create( AllValidationErrors );
end;

function TgIdentityObject.GetID: Variant;
begin
  Result := FID;
end;

function TgIdentityObject.GetIsModified: Boolean;
var
  RTTIProperty: TRTTIProperty;
begin
  Result := False;
  for RTTIProperty in G.PersistableProperties(Self) do
    If IsPropertyModified(RTTIProperty) Then
      Exit(True);
end;


function TgIdentityObject.GetObjectChildPathName(AChild: TgBase = nil): string;
begin
  Result := Format('%s[%s]',[Inherited,ID]);
end;

function TgIdentityObject.HasIdentity: Boolean;
var
  VarTypeWord: Word;
begin
  VarTypeWord := VarType(ID);
  case VarTypeWord of
    varEmpty, varNull: Result := False;
    varSmallint, varInteger, varSingle, varDouble, varCurrency, varDate, varShortInt, varByte, varWord, varLongWord, varInt64: Result := ID > 0;
    varString, varUString: Result := ID > '';
  else
    Result := False;
  end;
end;

class function TgIdentityObject.PersistenceManager: TgPersistenceManager;
begin
  Result := G.PersistenceManager(Self);
  if Not Assigned(Result) then
    raise E.CreateFmt('%s has no persistence manager.', [ClassName]);
end;

function TgIdentityObject.IsPropertyModified(const APropertyName: string): Boolean;
begin
  Result := IsPropertyModified(G.PropertyByName(Self, APropertyName));
end;

function TgIdentityObject.IsPropertyModified(ARTTIProperty: TRttiProperty): Boolean;
var Value1,Value2: Variant;
begin
  if ARTTIProperty.PropertyType.IsRecord then
    Result := Not (G.RecordProperty(ARTTIProperty).Getter.Invoke(ARTTIProperty.GetValue(Self) , []).AsVariant = G.RecordProperty(ARTTIProperty).Getter.Invoke(ARTTIProperty.GetValue(OriginalValues), []).AsVariant)
  Else If Not ARTTIProperty.PropertyType.IsInstance Then
    Result := Self.DoGetValues(ARTTIProperty,Value1) and OriginalValues.DoGetValues(ARTTIProperty.Name,Value2) and  (Value1 <> Value2)
  Else if ARTTIProperty.PropertyType.AsInstance.MetaclassType.InheritsFrom(TgIdentityObject) then
    Result := TgIdentityObject(ARTTIProperty.GetValue(Self).AsObject).IsModified
  Else
    Result := False;
end;

function TgIdentityObject.Load: Boolean;
begin
  DoLoad;
  Result := IsLoaded;
end;

procedure TgIdentityObject.RemoveIdentity;
begin
  case VarType(ID) of
    varSmallint, varInteger, varSingle, varDouble, varCurrency, varDate, varShortInt, varByte, varWord, varLongWord, varInt64: ID := 0;
    varString: ID := '';
  end;
end;

class function TgIdentityObject.PersistenceManagerPath: String;
begin
  Result:=  ApplicationPath + IncludeTrailingPathDelimiter('PersistanceManagers');
end;

procedure TgIdentityObject.Rollback;
begin
  PersistenceManager.RollBack(Self);
end;

procedure TgIdentityObject.Save;
begin
  IsSaving := True;
  try
    If CanSave Then
      DoSave;
  finally
    IsSaving := False;
  End;
end;

procedure TgIdentityObject.SetID(const AValue: Variant);
var
  HadIdentity: Boolean;
  IdentityList: TgIdentityList;
  RTTIProperty: TRTTIProperty;
begin
  if FID <> AValue then
  Begin
    HadIdentity := HasIdentity;
    FID := AValue;
    IsLoaded := False;
    if HadIdentity then
    Begin
      for RTTIProperty in G.IdentityListProperties(Self) do
      begin
        IdentityList := TgIdentityList(Inspect(RTTIProperty));
        if Assigned(IdentityList) then
          IdentityList.Active := False;
      end;
    End;
  End;
end;

procedure TgIdentityObject.SetStates(const AIndex: TgBase.TState;
  const AValue: Boolean);
var
  OldStates: TStates;
begin
  OldStates := FStates;
  inherited;
  case AIndex of
    osAutoCreating: ;
    osInspecting: ;
    osCreatingOriginalValues: ;
    osOriginalValues: ;
    osLoaded,osLoading
    : if AValue And Not (AIndex in OldStates) then
        InitializeOriginalValues;
    osSaving: ;
    osDeleting: ;
    osOrdered: ;
    osFiltered: ;
    osSorted: ;
    osActivating: ;
    osActive: ;
  end;
end;

procedure TgIdentityObject.StartTransaction(ATransactionIsolationLevel: TgTransactionIsolationLevel = ilReadCommitted);
begin
  PersistenceManager.StartTransaction(Self, ATransactionIsolationLevel);
end;

{ TgPersistenceManagerFile }

procedure TgPersistenceManagerFile.ActivateList(AIdentityList: TgIdentityList);
var
  List: TList;
  IdentityObject: TgIdentityObject;
begin
  if Length(G.Attributes(AIdentityList,NotPersistable)) > 0 then exit;
  List := TList.Create;
  try
    List.ItemClass := AIdentityList.ItemClass;
    LoadList(List);
    List.Where := AIdentityList.ExtendedWhere;
    List.Filter;
    AIdentityList.Clear;
    AIdentityList.IsFiltered := List.IsFiltered;
    for IdentityObject in List do
    begin
      AIdentityList.Add;
      // Use Items instead of Current, because Current can cause recursion.
      AIdentityList.Items[AIdentityList.CurrentIndex].Assign(IdentityObject);
      AIdentityList.Items[AIdentityList.CurrentIndex].IsLoaded := True;
    end;
  finally
    List.Free;
  end;
end;

procedure TgPersistenceManagerFile.AssignChanged(ASourceObject, ADestinationObject: TgIdentityObject);
Var
  SourceObject : TgBase;
  DestinationObject : TgBase;
  RTTIProperty : TRTTIProperty;
Begin
  For RTTIProperty In G.AssignableProperties(ASourceObject) Do
  Begin
    If RTTIProperty.PropertyType.IsInstance Then
    Begin
      SourceObject := TgBase(ASourceObject.Inspect(RTTIProperty));
      If Assigned(SourceObject) And SourceObject.InheritsFrom(TgBase) Then
      Begin
        DestinationObject := TgBase(RTTIProperty.GetValue(ADestinationObject).AsObject);
        if Assigned(DestinationObject) And ADestinationObject.Owns(DestinationObject) Then
        Begin
         if DestinationObject.InheritsFrom(TgIdentityObject) then
           AssignChanged(TgIdentityObject(SourceObject), TgIdentityObject(DestinationObject))
         Else If DestinationObject.InheritsFrom(TgBase) Then
           ADestinationObject.Assign(ASourceObject)
        End
        Else if RTTIProperty.IsWritable then
          RTTIProperty.SetValue(ADestinationObject, RTTIProperty.GetValue(ASourceObject));
      End;
    End
    Else if ASourceObject.IsPropertyModified(RTTIProperty) then
      RTTIProperty.SetValue(ADestinationObject, RTTIProperty.GetValue(ASourceObject));
  End;
end;

procedure TgPersistenceManagerFile.Commit(AObject: TgIdentityObject);
begin

end;

function TgPersistenceManagerFile.Count(AIdentityList: TgIdentityList): Integer;
var
  List: TList;
begin
  List := TList.Create;
  try
    List.ItemClass := AIdentityList.ItemClass;
    LoadList(List);
    List.Where := AIdentityList.ExtendedWhere;
    List.Filter;
    Result := List.Count;
  finally
    List.Free;
  end;
end;

procedure TgPersistenceManagerFile.CreatePersistentStorage;
var
  List: TList;
begin
  ForceDirectories(ExtractFilePath(FileName));
  List := TList.Create;
  try
    List.ItemClass := ForClass;
    StringToFile(List.Serialize(TgSerializerXML), FileName);
  finally
    List.Free;
  end;
end;

procedure TgPersistenceManagerFile.DeleteObject(AObject: TgIdentityObject);
var
  List: TList;
  ID : String;
begin
  List := TList.Create;
  try
    List.ItemClass := TgBaseClass(AObject.ClassType);
    LoadList(List);
    if Locate(List, AObject) then
      List.Delete
    Else
    Begin
      ID := AObject.ID;
      Raise E.CreateFmt('Delete failed. %s with an key of %s not found.', [AObject.ClassName, ID]);
    End;
    SaveList(List);
  finally
    List.Free;
  end;
end;

function TgPersistenceManagerFile.Filename: String;
begin
  Result := Format('%s%s.xml', [G.DataPath, ForClass.FriendlyName]);
end;

procedure TgPersistenceManagerFile.LoadList(const AList: TgPersistenceManagerFile.TList);
begin
  if Not PersistentStorageExists then
    CreatePersistentStorage;
  AList.Deserialize(TgSerializerXML, FileToString(FileName));
end;

procedure TgPersistenceManagerFile.LoadObject(AObject: TgIdentityObject);
var
  List: TList;
begin
  List := TList.Create;
  try
    List.ItemClass := TgBaseClass(AObject.ClassType);
    LoadList(List);
    If Locate(List, AObject) Then
    Begin
      AObject.Assign(List.Current);
      AObject.IsLoaded := True;
    End
    Else
    Begin
      AObject.IsLoaded := False;
      AObject.RemoveIdentity;
    End;
  finally
    List.Free;
  end;
end;

function TgPersistenceManagerFile.Locate(const AList: TgPersistenceManagerFile.TList; AObject: TgIdentityObject): Boolean;
begin
  // We use a While loop instead of a For-In loop to preserve the CurrentIndex value
  AList.First;
  while Not AList.EOL do
  Begin
    if AList.Current.ID = AObject.ID then
      Exit(True);
    AList.Next;
  End;
  Result := False;
end;

function TgPersistenceManagerFile.PersistentStorageExists: Boolean;
begin
  Result := FileExists(FileName);
end;

procedure TgPersistenceManagerFile.RollBack(AObject: TgIdentityObject);
begin

end;

procedure TgPersistenceManagerFile.SaveList(const AList: TgPersistenceManagerFile.TList);
begin
  ForceDirectories(ExtractFilePath(FileName));
  StringToFile(AList.Serialize(TgSerializerXML), FileName);
end;

procedure TgPersistenceManagerFile.SaveObject(AObject: TgIdentityObject);
var
  HasIdentity: Boolean;
  List: TList;
begin
  // To save an identity object, the object must either have a valid ID
  // or descend from TgIDObject, in which case we'll assign an ID if needed.
  HasIdentity := AObject.HasIdentity;
  if Not (HasIdentity Or AObject.InheritsFrom(TgIDObject)) then
    raise  E.CreateFmt('Attempted to save a %s without an ID.', [AObject.ClassName]);
  List := TList.Create;
  try
    List.ItemClass := TgBaseClass(AObject.ClassType);
    LoadList(List);
    // Don't  bother trying to locate if there's no ID
    If Not HasIdentity Or Not Locate(List, AObject) then
      List.Add;
    // Assign an ID if none given
    if Not HasIdentity then
    Begin
      List.LastID := List.LastID + 1;
      AObject.ID := List.LastID;
    End;
    AssignChanged(AObject, List.Current);
    SaveList(List);
  finally
    List.Free;
  end;
end;

procedure TgPersistenceManagerFile.StartTransaction(AObject: TgIdentityObject; ATransactionIsolationLevel: TgTransactionIsolationLevel = ilReadCommitted);
begin

end;

procedure TgIdentityList.Assign(ASource: TgBase);
begin
  // Never assign an identity list, because the data can be
  // retrieved through the persistence mamanager.
  Active := False;
end;

procedure TgIdentityList.AssignActive(const AValue: Boolean);
begin
  if AValue then
    Include(FStates, osActive)
  else
    Exclude(FStates, osActive);
end;

procedure TgIdentityList.Delete;
begin
  EnsureActive;
  Current.Delete;
  inherited Delete;
end;

procedure TgIdentityList.EnsureActive;
begin
  if Not Active then
    Active := True;
end;

function TgIdentityList.ExtendedWhere: String;
var
  RTTIProperty: TRTTIProperty;
  IdentityObjectClass: TgIdentityObjectClass;
  IDString: String;
  OwnerObject: TgIdentityObject;
begin
  Result := Where;
  If CurrentKey > '' Then
  Begin
    if Result > '' then
      Result := Result + ' And ';
    Result := Result + Format('(ID = ''%s'')', [CurrentKey]);
  End
  Else
  for RTTIProperty in G.ObjectProperties(ItemClass) do
  begin
    IdentityObjectClass := TgIdentityObjectClass(RTTIProperty.PropertyType.AsInstance.MetaclassType);
    if IdentityObjectClass.InheritsFrom(TgIdentityObject) then
    Begin
      OwnerObject := TgIdentityObject(OwnerByClass(IdentityObjectClass));
      if Assigned(OwnerObject) then
      Begin
        IDString := OwnerObject.ID;
        if Result > '' then
          Result := Result + ' And';
        Result := Result + Format('(%s.ID = %s)', [RTTIProperty.Name, IDString]);
      End;
    End;
  end;
end;

procedure TgIdentityList.First;
begin
  EnsureActive;
  inherited;
end;

function TgIdentityList.GetActive: Boolean;
begin
  Result := osActive in FStates;
end;

function TgIdentityList.GetBOL: Boolean;
begin
  EnsureActive;
  Result := inherited GetBOL;
end;

function TgIdentityList.GetCount: Integer;
begin
  if Not Active then
    Result := ItemClass.PersistenceManager.Count(Self)
  Else
    Result := Inherited GetCount;
end;

function TgIdentityList.GetCurrent: TgIdentityObject;
Begin
  if FList.Count = 0 then
    EnsureActive;
  Result := TgIdentityObject(Inherited GetCurrent);
End;

function TgIdentityList.GetCurrentKey: String;
begin
  Result := FCurrentKey;
end;

function TgIdentityList.GetEnumerator: TgEnumerator;
Begin
  Result.Init(Self);
End;

function TgIdentityList.GetEOL: Boolean;
begin
  EnsureActive;
  Result := inherited GetEOL;
end;

function TgIdentityList.GetIndexString: string;
begin
  Result := Current.ID;
end;

function TgIdentityList.GetItemClass: TgIdentityObjectClass;
begin
  Result := TgIdentityObjectClass(Inherited GetItemClass);
end;

function TgIdentityList.GetItems(AIndex : Integer): TgIdentityObject;
Begin
  Result := TgIdentityObject(Inherited GetItems(AIndex));
End;

function TgIdentityList.IndexOf(const AKey: String): Integer;
begin
  For Result := 0 To Count - 1 do
  Begin
    If TgIdentityObject(Items[Result]).ID = AKey Then
      Exit;
  End;
  Result := -1;
end;

procedure TgIdentityList.Last;
begin
  EnsureActive;
  inherited;
end;

procedure TgIdentityList.Next;
begin
  EnsureActive;
  inherited;
end;

procedure TgIdentityList.Previous;
begin
  EnsureActive;
  inherited;
end;

procedure TgIdentityList.Save;
var
  Counter: Integer;
begin
  if Length(G.Attributes(Self,NotPersistable)) = 0 then
    for Counter := 0 to FList.Count - 1 do
      Items[Counter].Save;
end;

procedure TgIdentityList.SetActive(const AValue: Boolean);
begin
  IsFiltered := False;
  IsOrdered := False;
  if AValue then
  Begin
    IsActivating := True;
    try
      Clear;
      if Length(G.Attributes(Self,NotPersistable)) = 0 then
        ItemClass.PersistenceManager.ActivateList(Self);
      if Not IsFiltered then
        Filter;
      if Not IsOrdered then
        Sort;
    finally
      IsActivating := False;
    end;
    AssignActive(True);
    First;
  End
  Else
  Begin
    Clear;
    AssignActive(False);
  End;
end;

procedure TgIdentityList.SetCurrentIndex(const AIndex: Integer);
begin
  inherited;
end;

procedure TgIdentityList.SetCurrentKey(const AValue: String);
begin
  If Buffered Then
  Begin
    If Not Active Then
      Active := True;
    CurrentIndex := IndexOf(AValue);
  End
  Else If ( AValue = '' ) Or  ( FCurrentKey <> AValue ) Then
  Begin
    Active := False;
    FCurrentKey := AValue;
    If FCurrentKey > '' Then
      Active := True;
  End;
end;

procedure TgIdentityList.SetIndexString(const AValue: String);
begin
  CurrentKey := AValue;
end;

procedure TgIdentityList.SetItemClass(const Value: TgIdentityObjectClass);
begin
  Inherited SetItemClass(Value);
end;

procedure TgIdentityList.SetItems(AIndex : Integer; const AValue: TgIdentityObject);
Begin
  Inherited SetItems(AIndex, AValue);
End;

procedure TgIdentityList.SetWhere(const AValue: string);
begin
  if AValue <> Where then
  Begin
    Active := False;
    inherited;
  End;
end;

constructor TgIdentityList<T>.Create(AOwner: TgBase = nil);
begin
  Inherited Create(AOwner);
  ItemClass := T;
end;

class function TgIdentityList<T>.AddAttributes(ARTTIProperty: TRttiProperty): System.TArray<System.TCustomAttribute>;
begin
  Result := inherited AddAttributes(ARTTIProperty);
  if SameText(ARTTIProperty.Name, 'Current') then
  Begin
    SetLength(Result, Length(Result) + 3);
    Result[Length(Result) - 3] := NotAutoCreate.Create;
    Result[Length(Result) - 2] := NotSerializable.Create;
    Result[Length(Result) - 1] := NotAssignable.Create;
  End;
end;

function TgIdentityList<T>.GetCurrent: T;
Begin
  Result := T(Inherited GetCurrent);
End;

function TgIdentityList<T>.GetEnumerator: TgEnumerator;
Begin
  Result.Init(Self);
End;

function TgIdentityList<T>.GetItems(AIndex : Integer): T;
Begin
  Result := T(Inherited GetItems(AIndex));
End;

procedure TgIdentityList<T>.SetItems(AIndex : Integer; const AValue: T);
Begin
  Inherited SetItems(AIndex, AValue);
End;

function TgIdentityList<T>.TryGet(const Key: String; out Item: T): Boolean;
var
  Index: Integer;
begin
  if Active and Buffered and (IndexOf(Key) < 0) then exit(False);
  CurrentKey := Key;
  Result := not Eol;
  if Result then
    Item := Current;
end;

class function TgIdentityList<T>._ItemClass: TgBaseClass;
begin
  Result := T;
end;

function TgIdentityList<T>.TgEnumerator.GetCurrent: T;
begin
  FList.CurrentIndex := FCurrentIndex;
  Result := FList.Current;
end;

function TgIdentityList<T>.TgEnumerator.GetCurrentOriginalValues: TgOriginalValues;
begin
  if Assigned(Current) then
    Result := Current.OriginalValues
  else
    Result := nil;
end;

procedure TgIdentityList<T>.TgEnumerator.Init(AList: TgIdentityList<T>);
begin
  FList := AList;
  FList.First;
  FCurrentIndex := -1;
end;

function TgIdentityList<T>.TgEnumerator.MoveNext: Boolean;
begin
  If FList.Count = 0 Then
    Exit(False);
  if FCurrentIndex > -1 then
  Begin
    FList.CurrentIndex := FCurrentIndex;
    FList.Next;
  End;
  Inc(FCurrentIndex);
  Result := Not FList.EOL;
end;

function TgModel.GetController: TgController;
begin
  Result := TgController(Owner);
end;

{ TgModel }

function TgModel.IsAuthorized(var AToken: String): Boolean;
begin
  // ID Integer - Expiration DateTime


  Result := True;
end;

function TgModel.PersistenceSegmentationString: String;
begin
  Result := '';
end;

class procedure TgModel.Register;
begin

end;

function TString50.GetValue: String;
begin
  Result := FValue;
end;

class operator TString50.implicit(AValue: TString50): String;
begin
  Result := AValue.FValue;
end;

procedure TString50.SetValue(const AValue: String);
begin
  FValue := Copy(AValue, 1, 50);
end;

class operator TString50.implicit(AValue: Variant): TString50;
begin
  Result.Value := AValue;
end;

class operator TString50.Implicit(AValue: TString50): Variant;
begin
  Result := AValue.Value;
end;

constructor G.TgIdentityObjectClassProperty.Create(AIdentityObjectClass: TgIdentityObjectClass; ARTTIProperty: TRTTIProperty);
begin
  IdentityObjectClass := AIdentityObjectClass;
  RTTIProperty := ARTTIProperty;
end;

function TgIdentityList.TgEnumerator.GetCurrent: TgIdentityObject;
begin
  FList.CurrentIndex := FCurrentIndex;
  Result := TgIdentityObject(FList.Current);
end;

procedure TgIdentityList.TgEnumerator.Init(AList: TgList);
begin
  FList := AList;
  FList.First;
  FCurrentIndex := -1;
end;

function TgIdentityList.TgEnumerator.MoveNext: Boolean;
begin
  If FList.Count = 0 Then
    Exit(False);
  if FCurrentIndex > -1 then
  Begin
    FList.CurrentIndex := FCurrentIndex;
    FList.Next;
  End;
  Inc(FCurrentIndex);
  Result := Not FList.EOL;
end;

constructor TgIDObject.Create(AOwner: TgBase = nil);
begin
  Inherited Create(AOwner);

  // If this is a singleton, load it.
  If Not IsOriginalValues And (Not Assigned(AOwner) Or AOwner.IsAutoCreating) And (Length(G.Attributes(Self, Singleton)) > 0) Then
  Begin
    ID := 1;
    Load;
  End;
end;



{ TgSerializer.THelper.TgComparer }

function TgSerializer.THelper.TComparer.Compare(const Left,
  Right: TPair<TgBaseClass, THelperClass>): Integer;
  function ParentCount(Value: TClass): Integer;
  begin
    Result := 0;
    if Assigned(Value) then
      Result := 1 + ParentCount(Value.ClassParent);
  end;

begin
    Result := -CompareValue(ParentCount(Left.Key),ParentCount(Right.Key));
    if Result = 0 then
      Result := -CompareValue(ParentCount(Left.Value),ParentCount(Right.Value));
end;

{ TgSerializerStackBase<T> }

constructor TgSerializerStackBase<T>.Create;
begin
  inherited;
  FNodeStack := TStack<T>.Create;
end;

destructor TgSerializerStackBase<T>.Destroy;
begin
  FreeAndNil(FNodeStack);
  inherited;
end;

function TgSerializerStackBase<T>.GetCurrentNode: T;
begin
  Result := FNodeStack.Peek;
end;

procedure TgSerializerStackBase<T>.TemporaryCurrentNode(Node: T;
  Proc: TProcedure);
begin
  FNodeStack.Push(Node);
  try
    Proc;
  finally
    FNodeStack.Pop;
  end;
end;

{ TgNodeCSV }

function TgNodeCSV.Add(const Name, Value: String): Integer;
begin
  Result := Add(Format('%s%s%s',[Name,NameValueSeparator,Value]));
end;

procedure TgNodeCSV.Add(Value: TgNodeCSV);
var Index: Integer;
begin
  Index := Add(Value.Name,'');
//0  Value.Name := '';
  Objects[Index] := Value;
end;

function TgNodeCSV.AddChild(const Name: String): TgNodeCSV;
begin
  Result := TgNodeCSV.Create(Owner,Name,Self);
  Add(Result);
end;

function TgNodeCSV.AddItem(Index: Integer): TgNodeCSV;
begin
  Result := TgNodeCSV.Create(Owner,Format('%s[%d]',[Name,Index]),Self);
  Add(Result);
end;

constructor TgNodeCSV.Create(Owner: TgSerializerCSV; const Name: String;
  ParentNode: TgNodeCSV);
begin
  inherited Create;
  FOwner := Owner;
  FName := Name;
  FParentNode := ParentNode;

end;

destructor TgNodeCSV.Destroy;
var Index: Integer;
begin
  for Index := 0 to Count-1 do
    if Objects[Index] is TgNodeCSV then
      Objects[Index].Free;
  inherited;
end;


procedure TgNodeCSV.ForEach(Anon: TForEach);
var
  Index: Integer;
begin
  Index := Count-1;
  for Index := 0 to Index do begin
    FOwner.AppendPath(Names[Index],procedure
      begin
        Anon(FOwner.AppendName,ValueFromIndex[Index],Objects[Index] as TgNodeCSV);
      end);
  end;
end;




procedure TgNodeCSV.ToRow(Columns: TStrings);
begin
  ForEach(procedure(const Name,Value: String; Node: TgNodeCSV)
    var
      ColumnIndex: Integer;
    begin
      if Value <> '' then begin
        ColumnIndex := FOwner.Headings.IndexOf(Name);
        if ColumnIndex < 0 then
          ColumnIndex := FOwner.Headings.Add(Name);

        if ColumnIndex >= 0 then begin
          while Columns.Count <= ColumnIndex do
            Columns.Add('');
          Columns[ColumnIndex] := Value;
        end;
      end
      else if Assigned(Node) then
        Node.ToRow(Columns);
    end);
end;

{ TgSerializerCSV.THelper<gBase> }

class procedure TgSerializerCSV.THelper<gBase>.Deserialize(AObject: gBase;
  ASerializer: TgSerializerCSV; ARTTIProperty: TRTTIProperty = Nil);
var
  RTTIProperty: TRTTIProperty;
  ObjectProperty: TgBase;
  gBaseClass: TgBaseClass;
  Value: Variant;
  HelperClass: TgSerializationHelperClass;
begin
  if not Assigned(ASerializer.CurrentRow) then begin
    ASerializer.ForEachRow(procedure
      begin
        Deserialize(AObject,ASerializer);
      end);
  end
  else
    For RTTIProperty In G.SerializableProperties(AObject) Do
    Begin
      if RTTIProperty.PropertyType.IsInstance then begin
        ASerializer.AppendPath(RTTIProperty.Name,procedure
          begin
//            ObjectProperty := TgBase(AObject.Inspect(RTTIProperty));
            if ASerializer.FObjectNames.IndexOf(ASerializer.AppendName) < 0 then exit;

            ObjectProperty := TgBase(RTTIProperty.GetValue(AObject.AsPointer).AsObject);
(*
            if not Assigned(ObjectProperty) then begin
              if ASerializer.GetColumnValue(_classname,AClassName) then
                gBaseClass := G.ClassByName(AClassName)
              else
                gBaseClass := TgBaseClass(RTTIProperty.PropertyType.AsInstance.MetaclassType);
              ObjectProperty := gBaseClass.Create(AObject);
              RTTIProperty.SetValue(Self,ObjectProperty);sd
            end;
*)
            if Assigned(ObjectProperty) then begin
              HelperClass := G.SerializationHelpers(TgSerializerCSV, ObjectProperty);
              HelperClass.Deserialize(ObjectProperty,ASerializer,RTTIProperty);
            end;
          end);
      end
      else begin
        if ASerializer.GetColumnValue(RTTIProperty.Name,Value) then
          AObject.Values[RTTIProperty.Name] := Value;
      end;
    end;
end;

class procedure TgSerializerCSV.THelper<gBase>.Serialize(AObject: gBase;
  ASerializer: TgSerializerCSV; ARTTIProperty: TRTTIProperty);
var
  DoubleValue: Double;
  ObjectProperty: TgBase;
  RTTIProperty: TRTTIProperty;
  Value: Variant;
begin
  For RTTIProperty In G.SerializableProperties(AObject) Do
  Begin
    if RTTIProperty.PropertyType.IsInstance then
    Begin
      ObjectProperty := TgBase(AObject.Inspect(RTTIProperty));
      If Assigned(ObjectProperty) And ObjectProperty.InheritsFrom(TgBase) Then
        ASerializer.AddObjectProperty(RTTIProperty, ObjectProperty);
    End
    Else
    Begin
      if (RTTIProperty.PropertyType.TypeKind = tkFloat) then
      Begin
       DoubleValue := RTTIProperty.GetValue(AObject.AsPointer).AsVariant;
       If SameText(RTTIProperty.PropertyType.Name, 'TDate') then
         Value := FormatDateTime('m/d/yyyy', DoubleValue)
       Else if SameText(RTTIProperty.PropertyType.Name, 'TDateTime') then
         Value := FormatDateTime('m/d/yyyy hh:nn:ss', DoubleValue)
       Else
         Value := DoubleValue;
      End
      Else
        Value := AObject.Values[RTTIProperty.Name];
      ASerializer.AddValueProperty(RTTIProperty.Name, Value);
    End
  End;
end;

{ TgSerializerCSV.THelperIdentityObject }

class procedure TgSerializerCSV.THelperIdentityObject.Serialize(
  AObject: TgIdentityObject; ASerializer: TgSerializerCSV;
  ARTTIProperty: TRTTIProperty);
begin
  if Not Assigned(ARTTIProperty) Or (Length(G.PropertyAttributes(G.TgPropertyAttributeClassKey.Create(ARTTIProperty, Composite))) > 0) then
    Inherited Serialize(AObject, ASerializer, ARTTIProperty)
  Else
    ASerializer.AddValueProperty('ID', AObject.ID);
end;

{ TgSerializerCSV.THelperList }

class procedure TgSerializerCSV.THelperList.Deserialize(AObject: TgList;
  ASerializer: TgSerializerCSV; ARTTIProperty: TRTTIProperty = Nil);
var
  HelperClass: TgSerializationHelperClass;
  Count: Integer;
begin
  if Assigned(ASerializer.CurrentRow) then begin
    if ASerializer.GetColumnValue('Count',Count) then begin
      for Count := 0 to Count-1 do begin
        AObject.Add;
        HelperClass := G.SerializationHelpers(TgSerializerCSV, AObject.Current);

        ASerializer.AppendPath(Format('[%d]',[Count]),procedure
          begin
            HelperClass.Deserialize(AObject.Current,ASerializer);
          end);
      end;

    end;
  end
  else ASerializer.ForEachRow(procedure
      begin
         AObject.Add;
         HelperClass := G.SerializationHelpers(TgSerializerCSV, AObject.Current);
         HelperClass.Deserialize(AObject.Current,ASerializer);
      end);
end;

class procedure TgSerializerCSV.THelperList.DeserializeUnpublishedProperty(
  AObject: TgList; ASerializer: TgSerializerCSV; const PropertyName: String);
var
  Counter: Integer;
  HelperClass: TgSerializationHelperClass;
  Node: TgNodeCSV;
  ANode: TgNodeCSV;
begin
  if SameText(PropertyName, 'List') then
  Begin
    Node := ASerializer.CurrentNode;
    for Counter := 0 to Node.Count - 1 do
    Begin
      AObject.Add;
      ANode := Node.Objects[Counter] as TgNodeCSV;
{ TODO : Shouldn't we use the classname to create this object? ASerializer.CurrentNode.Attributes['classname'] := ItemObject.QualifiedClassName; }
      HelperClass := G.SerializationHelpers(TgSerializerCSV, AObject.Current);
      ASerializer.TemporaryCurrentNode(ANode,procedure
        begin
          HelperClass.Deserialize(AObject.Current, ASerializer);
        end);
    End;
  End
  Else
    Inherited;
end;

class procedure TgSerializerCSV.THelperList.Serialize(AObject: TgList;
  ASerializer: TgSerializerCSV; ARTTIProperty: TRTTIProperty);
var
  ItemObject: TgBase;
  HelperClass: TgSerializationHelperClass;
  Index: Integer;
begin
  Inherited Serialize(AObject, ASerializer);
  if AObject.Count = 0 then exit;
  ASerializer.FBaseClass.Push(AObject.ItemClass);
  if Assigned(ARTTIProperty) then begin
    ASerializer.FAppendPath.Push(ARTTIProperty.Name);
    if AObject.Count > 0 then
      ASerializer.AddValueProperty('Count',AObject.Count);
  end;
  try
    Index := 0;
    for ItemObject in AObject do
    Begin
      if Assigned(ARTTIProperty) then begin
        ASerializer.AppendPath(Format('[%d]',[Index]),procedure
          begin
            ASerializer.TemporaryCurrentNode(ASerializer.CurrentNode.AddChild(Format('[%d]',[Index])),procedure
              begin
                if AObject.ItemClass <> ItemObject.ClassType then
                  ASerializer.CurrentNode.Values[_className] := ItemObject.QualifiedClassName;
                HelperClass := G.SerializationHelpers(TgSerializerCSV, ItemObject);
                HelperClass.Serialize(ItemObject, ASerializer);
              end);
          end);
      end
      else begin
        if AObject.ItemClass <> ItemObject.ClassType then
          ASerializer.CurrentNode.Values[_className] := ItemObject.QualifiedClassName;
        ASerializer.TemporaryCurrentNode(ASerializer.CurrentNode.AddItem(Index),procedure
          begin
            HelperClass := G.SerializationHelpers(TgSerializerCSV, ItemObject);
            HelperClass.Serialize(ItemObject, ASerializer);
          end);
      end;
      Inc(Index);
    End;
  finally
    ASerializer.FBaseClass.Pop;
    if Assigned(ARTTIProperty) then
      ASerializer.FAppendPath.Pop;
  end;
end;

{ TgSerializerCSV.THelperIdentityList }

class procedure TgSerializerCSV.THelperIdentityList.Serialize(
  AObject: TgIdentityList; ASerializer: TgSerializerCSV;
  ARTTIProperty: TRTTIProperty);
begin
  if Not Assigned(ARTTIProperty) Or (Length(G.PropertyAttributes(G.TgPropertyAttributeClassKey.Create(ARTTIProperty, Composite))) > 0) then
    Inherited Serialize(AObject, ASerializer, ARTTIProperty);
end;

{ TgSerializerCSV }

procedure TgSerializerCSV.AddObjectName(const Name: String);
var
  Index: Integer;
  AObject: String;
begin
  Index := Length(Name);
  while (Index > 0) and (Name[Index] <> '.') do
    Dec(Index);
  if Index = 0 then exit;
  AObject := Copy(Name,1,Index-1);
  if FObjectNames.IndexOf(AObject) >= 0 then exit;
  FObjectNames.Add(AObject);



end;

procedure TgSerializerCSV.AddObjectProperty(ARTTIProperty: TRTTIProperty; AObject: TgBase);
var
  HelperClass: TgSerializationHelperClass;
begin
  TemporaryCurrentNode(CurrentNode.AddChild(ARTTIProperty.Name),procedure
    begin
      HelperClass := G.SerializationHelpers(TgSerializerCSV, AObject);
      HelperClass.Serialize(AObject, Self, ARTTIProperty);
    end);
end;
procedure TgSerializerCSV.AddValueProperty(const AName: String; AValue: Variant);
begin
  GetCurrentColumnIndex(AName);
  CurrentNode.Values[AName] := AValue;
end;

procedure TgSerializerCSV.AppendPath(const Name: String; Proc: TProcedure);
begin
  FAppendPath.Push(Name);
  try
    Proc;
  finally
    FAppendPath.Pop;
  end;
end;

constructor TgSerializerCSV.Create;
begin
  inherited;
  FHeadings := TStringList.Create;
  FObjectNames := TStringList.Create;
  FObjectNames.Sorted := True;
  FDocument := TStringList.Create;
  FAppendPath := TStack<String>.Create;
  FBaseClass := TStack<TgBaseClass>.Create;
end;

procedure TgSerializerCSV.Deserialize(AObject: TgBase; const AString: String);
var
  HelperClass: TgSerializationHelperClass;
begin
  if FDocument.Count = 0 then
    Load(AString);
  HelperClass := G.SerializationHelpers(TgSerializerCSV, AObject);
  HelperClass.Deserialize(AObject, Self);
end;

destructor TgSerializerCSV.Destroy;
begin
  FreeAndNil(FObjectNames);
  FreeAndNil(FAppendPath);
  FreeAndNil(FBaseClass);
  FreeAndNil(FHeadings);
  FreeAndNil(FDocument);
  inherited;
end;

function TgSerializerCSV.ExtractClassName(const AString: string): string;
begin
  raise E.Create('Fix This');
//  Load(AString);
//  Result := CurrentNode.Attributes['classname'];
end;

procedure TgSerializerCSV.ForEachRow(Anon: TProcedure);
var
  Index: Integer;
  S: String;
begin
  FHeadings.Clear;
  if FDocument.Count > 0 then
    Headings.CommaText := FDocument[0];
  FObjectNames.Clear;
  for S in Headings do
    AddObjectName(S);

  FCurrentRow := TStringList.Create;
  try
    Index := FDocument.Count-1;
    for Index := 1 to Index do begin
      FCurrentRow.Clear;
      FCurrentRow.CommaText := FDocument[Index];
      Anon;
    end;
  finally
    FreeAndNil(FCurrentRow);
  end;

end;

function TgSerializerCSV.GetAppendName: String;
var
  Builder: TStringBuilder;
  S: String;
begin
  Builder := TStringBuilder.Create;
  try
    for S in FAppendPath do begin
      if (Builder.Length <> 0) and (S <> '') and (S[1] <> '[') then
        Builder.Append('.');
      if (S <> '') and ((Builder.Length <> 0) or (S[1] <> '[')) then
        Builder.Append(S);
    end;
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;

end;

function TgSerializerCSV.GetColumnValue(const AName: String;
  out Value: Integer): Boolean;
var
  V: Variant;
begin
  Result := GetColumnValue(AName,V);
  if Result then
    Value := V;
end;

function TgSerializerCSV.GetColumnValue(const AName: String;
  out Value: String): Boolean;
var Index: Integer;
begin
  Index := GetCurrentColumnIndex(AName,False);
  Result := (Index >= 0) and (Index < FCurrentRow.Count) and (FCurrentRow[Index] <> '');
  if Result then
     Value := FCurrentRow[Index];
end;

function TgSerializerCSV.GetCurrentColumnIndex(const AName: String; AutoAdd: Boolean): Integer;
var Index: Integer;
begin
  Index := -1;
  AppendPath(AName,procedure
    var
      Name: String;
    begin
      Name := AppendName;
      Index := FHeadings.IndexOf(Name);
      if AutoAdd and (Index < 0) then begin
        Index := FHeadings.Add(Name);
        AddObjectName(Name);
      end;

    end);
  Result := Index;
end;

function TgSerializerCSV.GetColumnValue(const AName: String; out Value: Variant): Boolean;
var
  S: String;
begin
  Result := GetColumnValue(AName,S);
  if Result then
    Value := S;
end;

procedure TgSerializerCSV.Load(const AString: String);
var
  BeginI,EndI: Integer;
begin
  FHeadings.Clear;
  FObjectNames.Clear;
  FDocument.Clear;
//  FDocument.StrictDelimiter := True;
  BeginI := 1;
  EndI := PosEx(#13#10,AString,BeginI);
  if EndI > 0 then repeat
    FDocument.Add(Copy(AString,BeginI,EndI-BeginI));
    BeginI := EndI + 2;
    EndI := PosEx(#13#10,AString,BeginI);
  until EndI = 0;
  EndI := Length(AString);
  if EndI > BeginI then
    FDocument.Add(Copy(AString,BeginI,EndI-BeginI));

//  FDocument.LineBreak := #13;
//  FDocument.DelimitedText := AString;
end;

class procedure TgSerializerCSV.Register;
begin
  RegisterRuntimeClasses([
      THelperBase, THelperList, THelperIdentityObject, THelperIdentityList
    ]);

end;

function TgSerializerCSV.Serialize(AObject: TgBase; ADefaultClass: TgBaseClass): String;
var
  HelperBaseClass: TgSerializationHelperClass;
  Node: TgNodeCSV;
  Row: TStringList;
begin
  FHeadings.Clear;
  FDocument.Clear;
  Node := TgNodeCSV.Create(Self);
  try
    FBaseClass.Push(TgBaseClass(AObject.ClassType));
    try
      TemporaryCurrentNode(Node,procedure
        begin
          HelperBaseClass := G.SerializationHelpers(TgSerializerCSV, AObject);
          HelperBaseClass.Serialize(AObject, Self);
        end);
    finally
      FBaseClass.Pop;
    end;
    Row := TStringList.Create;
    try
      Row.Clear;
      Node.ForEach(procedure(const Name,Value: String; Node: TgNodeCSV)
        var Index: Integer;
        begin
          if Assigned(Node) then begin
            Node.ToRow(Row);
            FDocument.Add(Row.CommaText);
            Row.Clear;
          end
          else begin
            Index := Headings.IndexOf(Name);
            while Index >= Row.Count do
              Row.Add('');
            Row[Index] := Value;
          end;
        end);
      if Row.Count > 0 then
        FDocument.Add(Row.CommaText);
    finally
      Row.Free;
    end;
  finally
    Node.Free;
  end;
  FDocument.Insert(0,FHeadings.CommaText);
  Result := FDocument.Text;
end;

procedure TgPersistenceManagerDBX.ActivateList(AIdentityList: TgIdentityList);
begin

end;

procedure TgPersistenceManagerDBX.AssignQueryParams(AParams: TParams; ABase: TgBase);
Var
  CollectionItem : TCollectionItem;
  Param : TParam;
begin
  For CollectionItem In AParams Do
  Begin
    Param := TParam(CollectionItem);
    Param.Value := ABase[Param.Name];
  End;
end;

procedure TgPersistenceManagerDBX.Commit(AObject: TgIdentityObject);
var
  Connection: TSQLConnection;
  GConnection: TgConnection;
begin
  GConnection := ConnectionDescriptor.GetConnection;
  Try
    GConnection.DecReferenceCount;
    Connection := TSQLConnection(GConnection.Connection);
    Connection.CommitFreeAndNil(TDBXTransaction(GConnection.Transaction));
  Finally
    ConnectionDescriptor.ReleaseConnection;
  End;
end;

function TgPersistenceManagerDBX.Count(AIdentityList: TgIdentityList): Integer;
begin
  Result := 0;
end;

procedure TgPersistenceManagerDBX.ExecuteStatement(const AStatement: String; ABase: TgBase);
begin
  WithQuery(
    Procedure(AQuery: TObject)
    var
      Query : TSQLQuery;
    Begin
      Query := TSQLQuery(AQuery);
      Query.SQL.Text := AStatement;
      AssignQueryParams(Query.Params, ABase);
      Query.ExecSQL;
    End
  );
end;

procedure TgPersistenceManagerDBX.LoadObject(AObject: TgIdentityObject);
begin
  WithQuery(
    Procedure(AQuery: TObject)
    var
      Query: TSQLQuery;
      Pair: TPair<String, String>;
    Begin
      Query := TSQLQuery(AQuery);
      Query.SQL.Text := LoadStatement;
      AssignQueryParams(Query.Params, AObject);
      Query.Open;
      for Pair in ObjectRelationalMap do
        AObject[Pair.Key] := Query.FieldValues[Pair.Value];
    End
  );
end;

procedure TgPersistenceManagerDBX.WithQuery(AWithQueryProcedure: TgWithQueryProcedure);
var
  SQLConnection: TSQLConnection;
  Query : TSQLQuery;
begin
  SQLConnection := TSQLConnection(ConnectionDescriptor.GetConnection.Connection);
  try
    SQLConnection.DriverName := DriverName;
    SQLConnection.Open;
    Query := TSQLQuery.Create(Nil);
    try
      Query.SQLConnection := SQLConnection;
      AWithQueryProcedure(Query);
    finally
      Query.Free;
    end;
  finally
    ConnectionDescriptor.ReleaseConnection;
  end;
end;

procedure TgPersistenceManagerDBX.RollBack(AObject: TgIdentityObject);
var
  Connection: TSQLConnection;
  GConnection: TgConnection;
begin
  GConnection := ConnectionDescriptor.GetConnection;
  Try
    GConnection.DecReferenceCount;
    Connection := TSQLConnection(GConnection.Connection);
    Connection.RollbackFreeAndNil(TDBXTransaction(GConnection.Transaction));
  Finally
    ConnectionDescriptor.ReleaseConnection;
  End;
end;

procedure TgPersistenceManagerDBX.StartTransaction(AObject: TgIdentityObject;ATransactionIsolationLevel: TgTransactionIsolationLevel = ilReadCommitted);
var
  Connection: TSQLConnection;
  GConnection: TgConnection;
  IsolationLevel: Integer;
begin
  case ATransactionIsolationLevel of
    ilReadCommitted: IsolationLevel := TDBXIsolations.ReadCommitted;
    ilSnapshot: IsolationLevel := TDBXIsolations.SnapShot;
    ilSerializable: IsolationLevel := TDBXIsolations.Serializable;
  else
    IsolationLevel := TDBXIsolations.ReadCommitted;
  end;
  GConnection := ConnectionDescriptor.GetConnection;
  Connection := TSQLConnection(GConnection.Connection);
  GConnection.Transaction := Connection.BeginTransaction(IsolationLevel);
end;

procedure TgPersistenceManager.Configure;
begin

end;

procedure TgPersistenceManager.Initialize;
begin

end;

constructor TgPersistenceManagerSQL.Create(AOwner: TgBase = nil);
begin
  inherited Create(AOwner);
  FObjectRelationalMap := TDictionary<String, String>.Create();
end;

destructor TgPersistenceManagerSQL.Destroy;
begin
  FreeAndNil(FObjectRelationalMap);
  inherited Destroy;
end;

class function TgPersistenceManagerSQL.ConformIdentifier(const AName: String): String;
begin
  Result := AName;
end;

procedure TgPersistenceManagerSQL.DeleteObject(AObject: TgIdentityObject);
begin
  ExecuteStatement(DeleteStatement, AObject);
end;

function TgPersistenceManagerSQL.DeleteStatement: String;
begin
  Result := Format('Delete From %s where %sID = :ID', [TableName, TableName]);
end;

procedure TgPersistenceManagerSQL.Initialize;
var
  BaseClass: TgBaseClass;
  RTTIProperty: TRTTIProperty;

  procedure PopulateComposite(APrefix: String; AClass: TgBaseClass);
  var
    PropertyName: String;
    RTTIProperty : TRTTIProperty;
    BaseClass : TgBaseClass;
  begin
    for RTTIProperty in G.PersistableProperties(AClass) do
    begin
      if RTTIProperty.PropertyType.IsInstance Then
      Begin
        BaseClass := TgBaseClass(RTTIProperty.PropertyType.AsInstance.MetaclassType);
        PropertyName := APrefix + '.' + RTTIProperty.Name;
        If BaseClass.InheritsFrom(TgIdentityObject) then
          FObjectRelationalMap.Add(PropertyName + '.ID', ConformIdentifier(PropertyName + 'ID'))
        else if G.IsComposite(RTTIProperty) then
          PopulateComposite(PropertyName, BaseClass);
      end
      else
        FObjectRelationalMap.Add(PropertyName, ConformIdentifier(PropertyName));
    end;
  end;

begin
  FConnectionDescriptor := G.ConnectionDescriptor(ConnectionDescriptorName);
  FObjectRelationalMap := TDictionary<String, String>.Create;
  for RTTIProperty in G.PersistableProperties(ForClass) do
  begin
    if SameText(RTTIProperty.Name, 'ID') then
      FObjectRelationalMap.Add(RTTIProperty.Name, ConformIdentifier(TableName + 'ID'))
    else if RTTIProperty.PropertyType.IsInstance Then
    Begin
      BaseClass := TgBaseClass(RTTIProperty.PropertyType.AsInstance.MetaclassType);
      If BaseClass.InheritsFrom(TgIdentityObject) then
        FObjectRelationalMap.Add(RTTIProperty.Name + '.ID', ConformIdentifier(RTTIProperty.Name + 'ID'))
      else if G.IsComposite(RTTIProperty) then
        PopulateComposite(RTTIProperty.Name, BaseClass);
    end
    else
      FObjectRelationalMap.Add(RTTIProperty.Name, ConformIdentifier(RTTIProperty.Name));
  end;
end;

function TgPersistenceManagerSQL.InsertStatement: String;
var
  First: Boolean;
  Pair : TPair<String, String>;
  StringBuilder : TStringBuilder;
begin
  StringBuilder := TStringBuilder.Create;
  try
    StringBuilder.AppendFormat('Insert Into %s', [TableName]);
    StringBuilder.AppendLine;
    StringBuilder.Append('(');
    First := True;
    for Pair in ObjectRelationalMap.ToArray do
    begin
      if First then
        First := False
      else
        StringBuilder.Append(', ');
      StringBuilder.Append(Pair.Value);
    end;
    StringBuilder.AppendLine(')');
    StringBuilder.Append('Values (');
    First := True;
    for Pair in ObjectRelationalMap.ToArray do
    begin
      if First then
        First := False
      else
        StringBuilder.Append(', ');
      StringBuilder.AppendFormat(':"%s"', [Pair.Key]);
    end;
    StringBuilder.Append(')');
    Result := StringBuilder.ToString;
  finally
    StringBuilder.Free;
  end;
end;

function TgPersistenceManagerSQL.LoadStatement: String;
var
  First: Boolean;
  StringBuilder: TStringBuilder;
  Pair: TPair<String, String>;
begin
  StringBuilder := TStringBuilder.Create;
  try
    StringBuilder.Append('Select ');
    First := True;
    for Pair in ObjectRelationalMap.ToArray do
    begin
      if First then
        First := False
      else
        StringBuilder.Append(', ');
      StringBuilder.Append(Pair.Value);
    end;
    StringBuilder.AppendLine;
    StringBuilder.AppendFormat('From %s', [TableName]);
    StringBuilder.AppendLine;
    StringBuilder.AppendFormat('Where %sID = :ID', [TableName]);
    Result := StringBuilder.ToString;
  finally
    StringBuilder.Free;
  end;
end;

procedure TgPersistenceManagerSQL.SaveObject(AObject: TgIdentityObject);
var
  Statement: String;
begin
  if AObject.HasIdentity then
    Statement := UpdateStatement(AObject)
  else
    Statement := InsertStatement;
  ExecuteStatement(Statement, AObject);
  if Not AObject.HasIdentity then
    AObject.ID := GetIdentity;
end;

function TgPersistenceManagerSQL.TableName: String;
begin
  Result := ConformIdentifier(ForClass.FriendlyName);
end;

function TgPersistenceManagerSQL.UpdateStatement(AObject: TgIdentityObject): String;
var
  First: Boolean;
  StringBuilder: TStringBuilder;
  Pair: TPair<String, String>;
begin
  StringBuilder := TStringBuilder.Create;
  try
    StringBuilder.AppendFormat('Update %s', [TableName]);
    StringBuilder.AppendLine;
    StringBuilder.Append('Set ');
    First := True;
    for Pair in ObjectRelationalMap.ToArray do
    begin
      if AObject.IsPropertyModified(Pair.Key) then
      Begin
        if First then
          First := False
        else
          StringBuilder.Append(', ');
        StringBuilder.AppendFormat('%s = :%s', [Pair.Value, Pair.Key]);
      End;
    end;
    if First then
      StringBuilder.Clear
    Else
    Begin
      StringBuilder.AppendLine;
      StringBuilder.AppendFormat('Where %sID = :ID', [TableName]);
    End;
    Result := StringBuilder.ToString;
  finally
    StringBuilder.Free;
  end;
end;

constructor PersistenceManagerClassName.Create(const AName: String);
begin
  inherited Create;
  FValue := AName;
end;

{ TgTagBase }

class constructor TgElement.Create;
begin
  inherited;
  _Tags := TDictionary<String, TClassOf>.Create;
  Register('list',TgElementList);
  Register('assign',TgElementAssign);
  Register('if',TgElementIf);
  Register('with',TgElementWith);
  Register('include',TgElementInclude);
  Register('select',TgElementSelect);
  Register('html',TgElementHTML);
end;

function TgElement.CopyNode(Source: IXMLNode): IXMLNode;
var
  Index: Integer;
  AName: String;
  ANode: IXMLNode;
  AgDocument: TgDocument;

begin
  if not GetgDocument(AgDocument) then
    raise E.Create('No document');
  Result := AgDocument.Target.CreateNode(Source.NodeName);
  Index := NodeAttributes.Count-1;
  for Index := 0 to Index do begin
    AName := NodeAttributes.Names[Index];
    Result.Attributes[AName] := NodeAttributes.Values[AName];
  end;

end;

constructor TgElement.Create(Owner: TgBase);
begin
  inherited;
  FCondition := True;
  FConditionSelf := True;
  FNodeAttributes := TStringList.Create;
end;

class function TgElement.CreateFromTag(Owner: TgElement;
  Node: IXMLNode; AgBase: TgBase): TgElement;
var
  AClass: TClassOf;
  NodeName: String;
  NodeValue: OleVariant;
  Index: Integer;
  Handled: Boolean;
  A: TCustomAttribute;
  ANotVisible: NotVisible;
  RTTIProperty: TRTTIProperty;
begin
  NodeName := Node.NodeName;
  if not _Tags.TryGetValue(NodeName, AClass) then
    AClass := TgElement;
  Result := AClass.Create(Owner);
  Result.TagName := Node.NodeName;
  Index := Node.AttributeNodes.Count-1;
  for Index := 0 to Index do begin
    NodeName := Node.AttributeNodes[Index].NodeName;
    RTTIProperty :=  Result.GetPropertyByName(NodeName);
    NodeValue := Result.ProcessValue(Node.AttributeNodes[Index].NodeValue);
    if NodeValue = null then
      NodeValue := '';
    if not GetAttribute<NotVisible>(RTTIProperty,ANotVisible) then
      Result.NodeAttributes.Values[NodeName] := NodeValue;
    if Assigned(RTTIProperty) and RTTIProperty.IsWritable then
      if RTTIProperty.PropertyType.Handle = TypeInfo(TObjectRef) then
        RTTIProperty.SetValue(Result,TObjectRef.NewValue(NodeValue,AgBase))
      else if RTTIProperty.PropertyType.IsInstance then
        RTTIProperty.SetValue(Result,AgBase.Objects[NodeValue])
      else begin
        Handled := False;
        for A in RTTIProperty.GetAttributes do
          if A is ImpliedExpressionEvaulator then begin
            if not Handled then
              Result[NodeName] := Eval(NodeValue,AgBase);
            Handled := True;
            Break;
          end;
        if not Handled then
          if not Result.DoSetValues(NodeName,NodeValue) then
            Result.DoSetValues(NodeName+'_',NodeValue);
      end;
  end;
end;
destructor TgElement.Destroy;
begin
  FreeAndNil(FNodeAttributes);
  inherited;
end;

class destructor TgElement.Destroy;
begin
  FreeAndNil(_Tags);
  inherited;
end;

function TgElement.ExpandPath(const AName: String; const APrefix: String = ''): String;
begin
  Result := '';
  if Pos('.',AName) > 0 then Exit(AName);
  if Assigned(Owner) and (Owner is TgElement) then
    Result := TgElement(Owner).ExpandPath(Object_.Name,'');
  if APrefix <> '' then
    Result := Result + '.' + APrefix;
  if (Result = '') then
    Result := AName
  else if (AName <> '') then
    Result := Result + '.' + AName;
end;

function TgElement.GetgBase: TgBase;
begin
  if Assigned(FgBase) then
    Result := FgBase
  else if Assigned(FOwner) and (FOwner is TgElement) then
    Result := (FOwner as TgElement).gBase
  else
    Result := nil;
end;

function TgElement.GetgDocument(out Value: TgDocument): Boolean;
begin
  Result := Assigned(FOwner) and (FOwner as TgElement).GetgDocument(Value);

end;

function TgElement.GetgDocument: TgDocument;
begin
  if not GetgDocument(Result) then
    Result := nil;
end;

function TgElement.GetModel: TgBase;
begin
  if Assigned(FOwner) and (FOwner is TgElement) then
    Result := (FOwner as TgElement).Model
  else
    Result := FgBase; // Bottom level has
end;

function TgElement.GetPropertyByName(const Name: String): TRTTIProperty;
begin
  Result := G.PropertyByName(Self,Name);
  if not Assigned(Result) then
    Result := G.PropertyByName(Self,Name + '_');
end;

function TgElement.GetValue(const Value: String): Variant;
begin
  Result := Eval(Value,gBase);
end;

procedure TgElement.ProcessChildNodes(SourceChildNodes,
  TargetChildNodes: IXMLNodeList);
var
  Next: TgElement;
  Index: Integer;
begin
  Index := SourceChildNodes.Count-1;
  for Index := 0 to Index do begin
    Next := TgElement.CreateFromTag(Self,SourceChildNodes[Index],gBase);
    try
      if not Next.Skip then
        Next.ProcessNode(SourceChildNodes[Index],TargetChildNodes);
    finally
      Next.Free;
    end;
  end;
end;

procedure TgElement.ProcessNode(Source: IXMLNode; TargetChildNodes: IXMLNodeList);
var
  Target: IXMLNode;
begin
  if ConditionSelf then begin
    Target := nil;
    case Source.NodeType of
      ntText
      : begin
          ProcessText(Source,TargetChildNodes);
          exit;
        end;
      else begin
        Target := CopyNode(Source);
        TargetChildNodes.Add(Target);
      end;
    end;

    if not Assigned(Target) then exit;
    ProcessChildNodes(Source.ChildNodes,Target.ChildNodes);
  end
  else
    ProcessChildNodes(Source.ChildNodes,TargetChildNodes);
end;

procedure TgElement.ProcessText(const Source: String; ProcessText,
  ProcessHTML: TProcessText);
var
  BeginingI: Integer;
  StartI,EndI: Integer;
  NewValue: String;
  AIsHTML: Boolean;
  AgBase: TgBase;
begin
  AgBase := gBase;
  if (Source = '') then
  else if not Assigned(AgBase) then
    ProcessText(Source)

  else begin
    // {}'s represent a expression to be evaulated
{ TODO : Handle Quotes Expression Evaulator}
{ TODO : Allow Nested  when searching the end;}
    StartI := Pos('{',Source);

    if StartI = 0 then
      ProcessText(Source) // nothing to do
    else begin
      BeginingI := 1;
      repeat
        EndI := PosEx('}',Source,StartI);
        if EndI = 0 then
          Break
        else begin
          if StartI <> BeginingI then
            ProcessText(Copy(Source,BeginingI,StartI-BeginingI));
          Inc(StartI);
          NewValue := Copy(Source,StartI,EndI-StartI);
          NewValue := EvalHTML(NewValue,AgBase,AIsHTML);
          if AIsHTML then
            ProcessHTML(NewValue)
          else
            ProcessText(NewValue);
          BeginingI := EndI+1;

          StartI := PosEx('{',Source,BeginingI);
        end;
      until StartI = 0;
      EndI := Length(Source)+1;
      if BeginingI < EndI then
        ProcessText(Copy(Source,BeginingI,EndI-BeginingI));
    end;
  end;
end;

procedure TgElement.ProcessText(SourceNode: IXMLNode;
  TargetChildNodes: IXMLNodeList);
var
  S: String;
  AgDocument: TgDocument;
begin
//    Result := Value // {} replacements
  AgDocument := gDocument;
  if not Assigned(AgDocument) then begin
    TargetChildNodes.Add(SourceNode.CloneNode(False));
    Exit;
  end;
  S := SourceNode.NodeValue;
  if Pos('{',S) = 0 then begin
    // Just return the value;
    TargetChildNodes.Add(AgDocument.Target.CreateNode(SourceNode.NodeValue,ntText));
    exit;
  end;
  ProcessText(S,
    procedure(const Text: String)
    begin
      TargetChildNodes.Add(AgDocument.Target.CreateNode(Text,ntText));
    end
   ,procedure(const HTML: String)
    var
      Text: String;
    begin
      Text := Trim(HTML);
      if not StartsText('<html>',Text) then
        Text:= '<html>'+Text+'</html>';
      AgDocument.ProcessText(Text,TargetChildNodes,gBase);
    end
    );
end;

function TgElement.ProcessValue(const Value: OleVariant): OleVariant;
var
  Builder: TStringBuilder;
  S: String;
begin
  if not VarIsStr(Value) or not Assigned(gBase) then
    Result := Value // {} replacements
  else begin
    S := Value;
    if Pos('{',S) = 0 then
      Exit(Value);

    Builder := TStringBuilder.Create;
    try
      ProcessText(S,
        procedure(const Text: String)
          begin
            Builder.Append(Text);
          end
       ,procedure(const HTML: String)
          begin
            Builder.Append(String(ProcessValue(HTML)));
          end);
      Result := Builder.ToString;
    finally
      Builder.Free;
    end;
  end;
end;

class procedure TgElement.Register(const TagName: String; AClass: TClassOf);
begin
  _Tags.Add(TagName,AClass);
end;


procedure TgElement.SetObject(const Value: TObjectRef);
begin
  FObject := Value;
  if Assigned(FObject.Base)  then
    FgBase := FObject.Base;

end;

function TgElement.Skip: Boolean;
begin
  Result := not Condition;
end;

{ TgDocument }

class function TgDocument._ProcessText(const Source: String;
  AgBase: TgBase): String;
begin
  if not _ProcessText(Source,Result,AgBase) then
    Result := '';
end;

procedure TgDocument.Clear;
begin
  Active := False;
  Active := True;
end;

constructor TgDocument.Create(Owner: TgBase);
begin
  inherited;
  Active := True;
end;

destructor TgDocument.Destroy;
begin
  Active := False;
  inherited;
end;

function TgDocument.GetgDocument(out Value: TgDocument): Boolean;
begin
  Result := True;
  Value := Self;
end;

function TgDocument.ProcessDocument(SourceDocument: IXMLDocument;
  TargetChildNodes: IXMLNodeList; AgBase: TgBase): Boolean;
begin
  Result := True;
  if Assigned(AgBase) then
    gBase := AgBase;
  ProcessChildNodes(SourceDocument.ChildNodes,TargetChildNodes);
end;


function TgDocument.ProcessFile(const AFileName: String; ASearchPath: String;
  TargetChildNodes: IXMLNodeList; AgBase: TgBase): Boolean;
begin
  if ASearchPath = '' then
    ASearchPath := SearchPath;
  Result := ProcessFile(FileSearch(AFileName,ASearchPath),TargetChildNodes,AgBase);
end;

function TgDocument.ProcessFile(const FileName: String;
  TargetChildNodes: IXMLNodeList; AgBase: TgBase): Boolean;
var
  SourceDocument: TXMLDocument;
  SourceDocumentInterface: IXMLDocument;
begin
  if (FileName = '') or not FileExists(FileName) then Exit(False);

  SourceDocument := TXMLDocument.Create(Nil);
  try
    SourceDocumentInterface := SourceDocument;
    SourceDocument.DOMVendor := GetDOMVendor('MSXML');
//    SourceDocument.Options := [doNodeAutoIndent];
    SourceDocument.LoadFromFile(FileName);
    Result := ProcessDocument(SourceDocument,TargetChildNodes,AgBase);
  finally
    SourceDocumentInterface := nil;
    SourceDocument := nil;
//      SourceDocument.Free;
  end;
end;

function TgDocument.ProcessFile(const AFileName: String; AStream: TStream): Boolean;
begin
  if not ProcessFile(AFileName,FTargetDocument.ChildNodes,Owner) then Exit(False);
  FTargetDocument.SaveToStream(AStream);
  Result := True;
  // TODO -cMM: TgDocument.ProcessFile default body inserted
end;

function TgDocument.ProcessText(const Source: String; var Target: String;
  AgBase: TgBase): Boolean;
begin
  Result := ProcessText(Source,FTargetDocument.ChildNodes,AgBase);
  if Result then
    Target := FTargetDocument.XML.Text;

end;

function TgDocument.ProcessText(const Source: String; TargetChildNodes: IXMLNodeList; AgBase: TgBase): Boolean;
var
  SourceDocument: TXMLDocument;
  SourceDocumentInterface: IXMLDocument;
begin
  SourceDocument := TXMLDocument.Create(Nil);
  try
    SourceDocumentInterface := SourceDocument;
    SourceDocument.DOMVendor := GetDOMVendor('MSXML');
    SourceDocument.Options := [doNodeAutoIndent];
    SourceDocument.LoadFromXML(Source);

    Result := ProcessDocument(SourceDocument,TargetChildNodes,AgBase);

  finally
    SourceDocumentInterface := nil;
    SourceDocument := nil;
//      SourceDocument.Free;
  end;
end;

procedure TgDocument.SetActive(const Value: Boolean);
begin
  if FActive = Value then exit;
  FActive := Value;
  if FActive then begin
    FTargetDocument := TXMLDocument.Create(Nil);
    FTargetDocumentInterface := FTargetDocument;
    FTargetDocument.DOMVendor := GetDOMVendor('MSXML');
    FTargetDocument.Options := [doNodeAutoIndent,doAttrNull];
    FTargetDocument.Active := True;
  end
  else begin
    FTargetDocumentInterface := nil;
    FTargetDocument := nil;
  end;
end;

class function TgDocument._ProcessText(const Source: String; var Target: String; AgBase: TgBase = nil): Boolean;
var
  gDocument: TgDocument;
begin
  gDocument := TgDocument.Create;
  try
    Result := gDocument.ProcessText(Source,Target,AgBase);
  finally
    gDocument.Free;
  end;

end;

{ TgServer }

destructor TgServer.Destroy;
begin
  If FMaxConnectionSemaphore > 0 Then
    CloseHandle(FMaxConnectionSemaphore);
  inherited Destroy;
end;

procedure TgServer.RemoveInactiveConnection;
var
  ConnectionDescriptor: TgConnectionDescriptor;
begin
  // This function must be called from within the critical section.
  for ConnectionDescriptor in ConnectionDescriptors do
  if ConnectionDescriptor.InactiveConnectionCount > 0 then
  begin
    ConnectionDescriptor.FreeInactive;
    Break;
  End;
end;

function TgServer.GetMaxConnectionSemaphore: Cardinal;
var
  MaximumCount: Integer;
begin
  // Need Name before Semaphore can be created.
  If ( FMaxConnectionSemaphore = 0 ) And ( Name > '' ) Then
  Begin
    If MaxConnections = 0 Then
      MaximumCount := MaxInt
    Else
      MaximumCount := MaxConnections;
    FMaxConnectionSemaphore := CreateSemaphore( nil, MaximumCount, MaximumCount, Nil );
  End;
  Result := FMaxConnectionSemaphore;
end;

function TgServer.Report: String;
var
  StringList: TStringList;
  ConnectionDescriptor: TgConnectionDescriptor;
begin
  StringList := TStringList.Create;
  try
    StringList.Add(Format('Name: %s'#9'Host: %s', [Name, Host]));
    for ConnectionDescriptor in ConnectionDescriptors do
      ConnectionDescriptor.Report(StringList);
    Result := StringList.Text;
  finally
    StringList.Free;
  end;
end;

function TgServer.ConnectionCount: Integer;
var
  ConnectionDescriptor: TgConnectionDescriptor;
begin
  Result := 0;
  for ConnectionDescriptor in ConnectionDescriptors do
    Result := Result + ConnectionDescriptor.ActiveConnectionCount + ConnectionDescriptor.InactiveConnectionCount;
end;

function TgServer.GetMaxConnections: Integer;
begin
  If FMaxConnections = 0 Then
    FMaxConnections := 5;
  Result := FMaxConnections;
end;

destructor TgConnection.Destroy;
begin
  ConnectionDescriptor.FreeConnection( Connection );
  inherited;
end;

constructor TgConnection.Create;
begin
  inherited;
  LinkEstablished := Now;
end;

procedure TgConnection.DecReferenceCount;
begin
  Dec(FReferenceCount);
end;

procedure TgConnection.EnsureActive;
begin

end;

function TgConnection.GetExpired: Boolean;
begin
  Result := (ConnectionDescriptor.TTL > 0) And (((Now - LastUsed) * 24 * 60 * 60) > ConnectionDescriptor.TTL);
end;

procedure TgConnection.IncReferenceCount;
begin
  Inc(FReferenceCount);
end;

function TgConnection.InUse: Boolean;
begin
  Result := FReferenceCount > 0;
end;

procedure TgConnectionDescriptorDBX.CreateConnection(AConnection: TgConnection);
var
  SQLConnection: TSQLConnection;
begin
  SQLConnection := TSQLConnection.Create(Nil);
  SQLConnection.LoadParamsOnConnect := False;
  SQLConnection.LoginPrompt := False;
  SQLConnection.DriverName := DriverName;
  SQLConnection.LibraryName := LibraryName;
  SQLConnection.VendorLib := VendorLib;
  SQLConnection.GetDriverFunc := GetDriverFunc;
  SQLConnection.Params.Assign(Params);
  SQLConnection.Open;
  AConnection.Connection := SQLConnection;
end;

function TgConnectionDescriptorDBX.EnsureActive(AConnection: TgConnection): Boolean;
begin
  Result := False;
end;

procedure TgConnectionDescriptorDBX.FreeConnection(AConnection: TObject);
begin
  AConnection.Free;
end;

constructor TgConnectionDescriptor.Create(AOwner: TgBase = nil);
begin
  inherited Create(AOwner);
  FCriticalSection := TCriticalSection.Create();
  FActiveConnectionList := TDictionary<Cardinal, TgConnection>.Create();
  FInactiveConnectionList := TQueue<TgConnection>.Create();
end;

destructor TgConnectionDescriptor.Destroy;
begin
  FreeAndNil(FInactiveConnectionList);
  FreeAndNil(FActiveConnectionList);
  FreeAndNil(FCriticalSection);
  inherited Destroy;
end;

function TgConnectionDescriptor.ActiveConnectionCount: Integer;
begin
  Result := FActiveConnectionList.Count;
end;

function TgConnectionDescriptor.GetConnection: TgConnection;
var
  ThreadID: Cardinal;
begin
  ThreadID := GetCurrentThreadId;

  FCriticalSection.Enter;
  try
    // Try to find an active connection using the current thread.
    Result := ReuseActiveConnection(ThreadID);
  finally
    FCriticalSection.Leave;
  end;

  // If no active connection is found
  If Not Assigned( Result ) Then
  Begin
    If WaitForSingleObject(Server.MaxConnectionSemaphore, Server.Timeout) <> WAIT_OBJECT_0 Then
      Raise E.Create('A timeout occurred waiting for a connection to go inactive.');

    // An inactive connection became available
    FCriticalSection.Enter;
    try

      // See if one is available in the inactive pool
      Result := ReuseInactiveConnection(ThreadID);

      // If no active or inactive connection is found, try to create a new one.
      If Not Assigned(Result) Then
        Result := GetNewConnection(ThreadID);

      // If not, remove an inactive connection from another connection descriptor's pool
      // and create a new connection.
      If Not Assigned( Result ) Then
      Begin
        Server.RemoveInactiveConnection;
        Result := GetNewConnection(ThreadID);
      End;
    finally
      FCriticalSection.Leave;
    end;
  End;

  //If no connection was returned, raise an exception
  If Assigned(Result) Then
    Result.LastUsed := Now;
  If Not Assigned( Result ) Then
    Raise E.Create( 'Could not create connection' );
end;

function TgConnectionDescriptor.GetNewConnection(AThreadID: Cardinal): TgConnection;
begin
  // This function must be called from within the critical section.
  Result := nil;
  If ( Server.MaxConnections = 0 ) Or ( Server.ConnectionCount < Server.MaxConnections ) Then
  Begin
    Result := TgConnection.Create;
    try
      Result.ThreadID := AThreadID;
      Result.ConnectionDescriptor := Self;
      CreateConnection(Result);
      FActiveConnectionList.AddOrSetValue(AThreadID, Result );
      Result.IncReferenceCount;
    except
      FreeAndNil( Result );
      Raise
    end;
  End;
end;

function TgConnectionDescriptor.InactiveConnectionCount: Integer;
begin
  Result := FInactiveConnectionList.Count;
end;

procedure TgConnectionDescriptor.ReleaseConnection;
var
  Connection: TgConnection;
  ThreadID: Cardinal;
begin
  FCriticalSection.Enter;
  Try
    ThreadID := GetCurrentThreadID;
    FActiveConnectionList.TryGetValue(ThreadID, Connection);
    If Not Assigned( Connection ) Then
      Raise E.CreateFmt( 'Cannot release connection for ''%s''.', [Name] );
    Connection.DecReferenceCount;
    If Not Connection.InUse Then
    Begin
      // Remove from active
      FActiveConnectionList.Remove(ThreadID);
      FInactiveConnectionList.Enqueue( Connection );
      ReleaseSemaphore(Server.MaxConnectionSemaphore, 1, nil);
    End;
  Finally
    FCriticalSection.Leave;
  End;
end;

procedure TgConnectionDescriptor.FreeInactive;
var
  Connection: TgConnection;
begin
  FCriticalSection.Enter;
  Try
    Connection := FInactiveConnectionList.Dequeue;
    Connection.Free;
  Finally
    FCriticalSection.Leave;
  End
end;

function TgConnectionDescriptor.GetParams: TStringList;
begin
  if Not Assigned(FParams) then
    FParams := TStringList.Create;
  Result := FParams;
end;

function TgConnectionDescriptor.GetParamString: String;
begin
  Result := Params.Text;
end;

function TgConnectionDescriptor.GetServer: TgServer;
begin
  Result := TgServer(OwnerByClass(TgServer));
end;

procedure TgConnectionDescriptor.Report(AStringList: TStringList);
var
  Connection: TgConnection;
begin
  FCriticalSection.Enter;
  Try
    AStringList.Add(Format('  %s:', [Name]));
    AStringList.Add('');
    AStringList.Add('    Active Connections');
    for Connection in FActiveConnectionList.Values do
      AStringList.Add(Format('      ThreadID: %d', [Connection.ThreadID]));
    AStringList.Add('');
    AStringList.Add('    Inactive Connections');
    for Connection in FInactiveConnectionList do
      AStringList.Add(Format('      Created: %s'#9'Last Used: %s', [FormatDateTime('dd/mm/yy hh:nn:ss', Connection.LinkEstablished), FormatDateTime('dd/mm/yy hh:nn:ss', Connection.LastUsed)]));
    AStringList.Add('');
  Finally
    FCriticalSection.Leave;
  End;
end;

function TgConnectionDescriptor.ReuseActiveConnection(AThreadID: Cardinal): TgConnection;
begin
  // This function must be called from within the critical section.
  FActiveConnectionList.TryGetValue(AThreadID, Result);
  If Assigned(Result) Then
    Result.IncReferenceCount;
end;

function TgConnectionDescriptor.ReuseInactiveConnection(AThreadID: Cardinal): TgConnection;
begin
  // This function must be called from within the critical section.
  Result := nil;
  If FInactiveConnectionList.Count >= 1 Then
  Begin
    Result := FInactiveConnectionList.Dequeue;
    Result.ThreadID := AThreadID;
    Try
      Result.EnsureActive;
      Result.IncReferenceCount;
      FActiveConnectionList.AddOrSetValue(AThreadID, Result );
    Except
      FreeAndNil(Result);
      Raise;
    End;
  End;
end;

procedure TgConnectionDescriptor.SetParamString(const AValue: String);
begin
  Params.Text := AValue;
end;

procedure TgPersistenceManagerDBXFirebird.Configure;
var
  Server: TgServer;
  ConnectionDescriptor: TgConnectionDescriptorDBXFirebird;
  DatabaseName: string;
begin
  Server := G.Server(DriverName);
  if Not Assigned(Server) then
  Begin
    Server := TgServer.Create;
    Server.Name := DriverName;
    Server.Host := 'localhost';
    Server.Port := 3050;
    Server.TimeOut := 10000;
    G.AddServer(Server);
  End;
  ConnectionDescriptor := TgConnectionDescriptorDBXFirebird(G.ConnectionDescriptor(Format('%s:%s', [DriverName, ForClass.UnitName])));
  if Not Assigned(ConnectionDescriptor) then
  Begin
    Server.ConnectionDescriptors.ItemClass := TgConnectionDescriptorDBXFirebird;
    Server.ConnectionDescriptors.Add;
    ConnectionDescriptor := TgConnectionDescriptorDBXFirebird(Server.ConnectionDescriptors.Current);
    ConnectionDescriptor.Name := Format('%s:%s', [DriverName, ForClass.UnitName]);
    DatabaseName := ExpandFileName(Format('%s%s.fdb', [G.DataPath, ForClass.UnitName]));
    ConnectionDescriptor.Params.Values['Database'] := Format('%s:%s', [Server.Host, DatabaseName]);
    ConnectionDescriptor.Params.Values['User'] := 'SYSDBA';
    ConnectionDescriptor.Params.Values['Password'] := 'masterkey';
    G.AddConnectionDescriptor(ConnectionDescriptor);
  end;
  ConnectionDescriptorName := ConnectionDescriptor.Name;
end;

function TgPersistenceManagerDBXFirebird.DriverName: string;
begin
  Result := 'FirebirdConnection';
end;

class function TgConnectionDescriptorDBXFirebird.DriverName: string;
begin
  Result := 'FirebirdConnection';
end;

class function TgConnectionDescriptorDBXFirebird.GetDriverFunc: string;
begin
  Result := 'getSQLDriverFIREBIRD';
end;

class function TgConnectionDescriptorDBXFirebird.LibraryName: string;
begin
  Result := 'dbx4fb.dll';
end;

class function TgConnectionDescriptorDBXFirebird.VendorLib: string;
begin
  Result := 'fbclient.DLL';
end;

procedure TgPersistenceManagerIBX.ActivateList(AIdentityList: TgIdentityList);
begin

end;

procedure TgPersistenceManagerIBX.AssignQueryParams(AParams: TParams; ABase: TgBase);
Var
  CollectionItem : TCollectionItem;
  Param : TParam;
begin
  For CollectionItem In AParams Do
  Begin
    Param := TParam(CollectionItem);
    Param.Value := ABase[Param.Name];
  End;
end;

procedure TgPersistenceManagerIBX.Commit(AObject: TgIdentityObject);
var
  GConnection: TgConnection;
begin
  GConnection := ConnectionDescriptor.GetConnection;
  Try
    GConnection.DecReferenceCount;
    TIBTransaction(GConnection.Transaction).Commit;
  Finally
    ConnectionDescriptor.ReleaseConnection;
  End;
end;

procedure TgPersistenceManagerIBX.Configure;
const
  sServerName = 'Firebird';
var
  Server: TgServer;
  ConnectionDescriptor: TgConnectionDescriptorIBX;
  DatabaseName: string;
begin
  Server := G.Server(sServerName);
  if Not Assigned(Server) then
  Begin
    Server := TgServer.Create;
    Server.Name := sServerName;
    Server.Host := 'localhost';
    Server.Port := 3050;
    Server.TimeOut := 10000;
    G.AddServer(Server);
  End;
  ConnectionDescriptor := TgConnectionDescriptorIBX(G.ConnectionDescriptor(Format('%s:%s', [sServerName, ForClass.UnitName])));
  if Not Assigned(ConnectionDescriptor) then
  Begin
    Server.ConnectionDescriptors.ItemClass := TgConnectionDescriptorIBX;
    Server.ConnectionDescriptors.Add;
    ConnectionDescriptor := TgConnectionDescriptorIBX(Server.ConnectionDescriptors.Current);
    ConnectionDescriptor.Name := Format('%s:%s', [sServerName, ForClass.UnitName]);
    DatabaseName := ExpandFileName(Format('%s%s.fdb', [G.DataPath, ForClass.UnitName]));
    ConnectionDescriptor.DatabaseName := Format('%s:%s', [Server.Host, DatabaseName]);
    ConnectionDescriptor.UserName := 'SYSDBA';
    ConnectionDescriptor.Password := 'masterkey';
    G.AddConnectionDescriptor(ConnectionDescriptor);
  end;
  ConnectionDescriptorName := ConnectionDescriptor.Name;
end;

class function TgPersistenceManagerIBX.ConformIdentifier(const AName: string): string;
begin
  Result := Uppercase(inherited ConformIdentifier(AName));
end;

function TgPersistenceManagerIBX.Count(AIdentityList: TgIdentityList): Integer;
begin
  Result := 0;
end;

procedure TgPersistenceManagerIBX.ExecuteStatement(const AStatement: String; ABase: TgBase);
begin
  WithQuery(
    Procedure(AQuery: TObject)
    var
      Query: TIBQuery;
    Begin
      Query := TIBQuery(AQuery);
      Query.SQL.Text := AStatement;
      AssignQueryParams(Query.Params, ABase);
      Query.ExecSQL;
    End
  );
end;

function TgPersistenceManagerIBX.GeneratorName: String;
begin
  Result := Format('%s_GEN', [TableName]);
end;

function TgPersistenceManagerIBX.GetIdentity: Variant;
var
  Identity: Integer;
begin
  WithQuery(
    Procedure(AQuery: TObject)
    var
      Query: TIBQuery;
    Begin
      Query := TIBQuery(AQuery);
      Query.SQL.Text := Format('Select gen_id("%s", 0) from rdb$database', [GeneratorName]);
      Query.Open;
      Identity := Query.Fields[0].AsInteger;
    End
  );
  Result := Identity;
end;

procedure TgPersistenceManagerIBX.LoadObject(AObject: TgIdentityObject);
begin
  WithQuery(
    Procedure(AQuery: TObject)
    var
      Query: TIBQuery;
      Pair: TPair<String, String>;
    Begin
      Query := TIBQuery(AQuery);
      Query.SQL.Text := LoadStatement;
      AssignQueryParams(Query.Params, AObject);
      Query.Open;
      if Not Query.Eof then
      Begin
        for Pair in ObjectRelationalMap do
          AObject[Pair.Key] := Query.FieldValues[Pair.Value];
        AObject.IsLoaded := True;
      End
      Else
        AObject.IsLoaded := False;
    End
  );
end;

procedure TgPersistenceManagerIBX.WithQuery(AWithQueryProcedure: TgWithQueryProcedure);
var
  Connection: TgConnection;
  IBConnection: TIBDatabase;
  Query : TIBQuery;
begin
  Connection := ConnectionDescriptor.GetConnection;
  IBConnection := TIBDatabase(Connection.Connection);
  try
    Query := TIBQuery.Create(Nil);
    try
      Query.Database := IBConnection;
      Query.Transaction := TIBTransaction(Connection.Transaction);
      Query.Transaction.StartTransaction;
      Try
        AWithQueryProcedure(Query);
        Query.Transaction.Commit;
      Except
        Query.Transaction.Rollback;
        Raise;
      End
    finally
      Query.Free;
    end;
  finally
    ConnectionDescriptor.ReleaseConnection;
  end;
end;

procedure TgPersistenceManagerIBX.RollBack(AObject: TgIdentityObject);
var
  GConnection: TgConnection;
begin
  GConnection := ConnectionDescriptor.GetConnection;
  Try
    GConnection.DecReferenceCount;
    TIBTransaction(GConnection.Transaction).Rollback;
  Finally
    ConnectionDescriptor.ReleaseConnection;
  End;
end;

procedure TgPersistenceManagerIBX.StartTransaction(AObject: TgIdentityObject;ATransactionIsolationLevel: TgTransactionIsolationLevel = ilReadCommitted);
var
  GConnection: TgConnection;
begin
  GConnection := ConnectionDescriptor.GetConnection;
  TIBTransaction(GConnection.Transaction).StartTransaction;
end;

procedure TgConnectionDescriptorIBX.CreateConnection(AConnection: TgConnection);
var
  Connection: TIBDatabase;
  Transaction : TIBTransaction;
begin
  Connection := TIBDatabase.Create(Nil);
  Transaction := TIBTransaction.Create(Nil);
  Transaction.DefaultDatabase := Connection;
  Connection.LoginPrompt := False;
  Connection.DatabaseName := DatabaseName;
  Connection.Params.Values['User_Name'] := UserName;
  Connection.Params.Values['Password'] := Password;
  Connection.Open;
  AConnection.Connection := Connection;
  AConnection.Transaction := Transaction;
end;

function TgConnectionDescriptorIBX.EnsureActive(AConnection: TgConnection): Boolean;
begin
  Result := False;
end;

procedure TgConnectionDescriptorIBX.FreeConnection(AConnection: TObject);
begin
  AConnection.Free;
end;

{ TgElementList }

procedure TgElementList.ProcessChildNodes(SourceChildNodes,
  TargetChildNodes: IXMLNodeList);
begin
  Object_.First;
  while not Object_.EOL do begin
    gBase := Object_.Current;
    inherited ProcessChildNodes(SourceChildNodes,TargetChildNodes);
    Object_.Next;
  end;
end;

procedure TgElementList.ProcessNode(Source: IXMLNode;
  TargetChildNodes: IXMLNodeList);
begin
  ProcessChildNodes(Source.ChildNodes,TargetChildNodes);
end;

Function TgHTMLExpressionEvaluator.GetValue(Const AVariableName : String) : Variant;
var
  RTTIProperty: TRTTIProperty;
Begin
  if FModel.DoGetProperties(AVariableName,RTTIProperty,FModel) and Assigned(RTTIProperty) And (RTTIProperty.PropertyType.Handle =  TypeInfo(TgHTMLString)) then
    FIsHTML := True;
  Result := FModel[AVariableName];
End;

constructor TgDictionary.Create(AOwner: TgBase = Nil);
begin
  inherited Create(AOwner);
  FDictionary := TDictionary<String, Variant>.Create();
end;

procedure TgDictionary.Delete(const APath: String);
begin
  FDictionary.Remove(APath);
end;

destructor TgDictionary.Destroy;
begin
  FreeAndNil(FDictionary);
  inherited Destroy;
end;

function TgDictionary.DoGetValues(const APath: string; out AValue: Variant): Boolean;
begin
  Result := True;
  if inherited DoGetValues(APath, AValue) then exit;
  if FDictionary.TryGetValue(APath, AValue) then exit;
  AValue := Unassigned;
end;

function TgDictionary.DoSetValues(const APath: string; AValue: Variant): Boolean;
begin
  Result := inherited DoSetValues(APath, AValue);
  if Not Result then
  Begin
    FDictionary.AddOrSetValue(APath, AValue);
    Result := True;
  End
End;

function TgDictionary.GetPathCount: Integer;
begin
  Result := inherited + FDictionary.Keys.Count;
end;

function TgDictionary.GetPaths(AIndex: Integer): String;
begin
  if AIndex < inherited GetPathCount then
    Result := inherited
  else begin
    Dec(AIndex,inherited GetPathCount);
    Result := FDictionary.Keys.ToArray[AIndex];
  end;
end;

{ TgElementIf }

procedure TgElementIf.ProcessNode(Source: IXMLNode;
  TargetChildNodes: IXMLNodeList);
var
  Index: Integer;
begin
  if Condition then begin
    Index := Source.ChildNodes.IndexOf('then');
    if Index >= 0 then
      Source := Source.ChildNodes['then'];
    if Assigned(Source) then
      ProcessChildNodes(Source.ChildNodes,TargetChildNodes);
  end
  else begin
    Index := Source.ChildNodes.IndexOf('else');
    if Index >= 0 then begin
      Source := Source.ChildNodes['else'];
      if Assigned(Source) then
        ProcessChildNodes(Source.ChildNodes,TargetChildNodes);
    end;
  end;
end;

function TgElementIf.Skip: Boolean;
begin
  Result := False;
end;

{ TgElementWith }

procedure TgElementWith.ProcessNode(Source: IXMLNode;
  TargetChildNodes: IXMLNodeList);
begin
  gBase := Object_;
  ProcessChildNodes(Source.ChildNodes,TargetChildNodes);
end;

{ TgElementAssign }

procedure TgElementAssign.ProcessNode(Source: IXMLNode;
  TargetChildNodes: IXMLNodeList);
begin
  gBase[Name] := ProcessValue(Value);
end;

{ TgElementInclude }

procedure TgElementInclude.ProcessNode(Source: IXMLNode;
  TargetChildNodes: IXMLNodeList);
var
  AgDocument: TgDocument;
begin
  if GetgDocument(AgDocument) then
    AgDocument.ProcessFile(FileName, SearchPath, TargetChildNodes);
end;


{ TgElementHTML }

constructor TgElementHTML.Create(Owner: TgBase);
var
  AgDocument: TgDocument;
begin
  inherited;
  // This is ment to handle nest html tags
  if GetgDocument(AgDocument)  then
    ConditionSelf := AgDocument.Target.ChildNodes.Count = 0;
end;

{ TgMemo }


function TgMemo.Add(const Value: String): Integer;
begin
  Result := Length(FValue);
  SetLength(FValue,Result+1);
  FValue[Result] := Value;

end;

function TgMemo.GetCount: Integer;
begin
  Result := Length(FValue);
end;

function TgMemo.GetItems(Index: Integer): String;
begin
  Result := FValue[Index];
end;

function TgMemo.GetValue: String;
var
  AStrings: TStringList;
  AStr: String;
begin
  if Length(FValue) = 0 then
    Result := ''
  else with TStringList.Create do try
    for AStr in FValue do
      Add(AStr);
    Result := Text;
  finally
    Free;
  end;
end;

class operator TgMemo.Implicit(AValue: TgMemo): Variant;
begin
  Result := AValue.GetValue;
end;

class operator TgMemo.Implicit(AValue: Variant): TgMemo;
begin
  Result.SetValue(AValue);
end;

function TgMemo.IndexOf(const Value: String): Integer;
begin
  Result := High(FValue);
  while (Result >= 0) and not SameText(Value,FValue[Result]) do
    Dec(Result);

end;

procedure TgMemo.SetCount(const Value: Integer);
begin
  SetLength(FValue,Value);
end;

procedure TgMemo.SetItems(Index: Integer; const Value: String);
begin
  if Index > High(FValue) then
    Count := Index+1;
  FValue[Index] := Value;
end;

procedure TgMemo.SetValue(const AValue: String);
var
  AStrings: TStringList;
  Index: Integer;

begin
  if Length(AValue) = 0 then
    SetLength(FValue,0)
  else with TStringList.Create do try
    Text := AValue;
    SetLength(FValue,Count);
    for Index := 0 to Count-1 do
      FValue[Index] := Strings[Index];
  finally
    Free;
  end;
end;

{ TgWebCookie }

function TgWebCookie.GetValue: String;
var
  S1: UInt64;
  S2: UInt64;
  T1: UInt64;
  T2: UInt64;
  Index: Integer;

begin
  if (FExpire = 0) and (FID = 0) then Exit('');
  S1 := pUInt64(@FExpire)^;
  S2 := Key;
  S2 := Cardinal(ID) or (S2 SHL 32);
  T1 := 0;
  T2 := 0;
  for Index := 0 to 31 do begin
    T1 := (T1 SHL 2) or ((S1 and $1) or ((S2 and $1) SHL 1));
    S1 := S1 SHR 1;
    S2 := S2 SHR 1;
  end;
  for Index := 0 to 31 do begin
    T2 := (T2 SHL 2) or ((S1 and $1) or ((S2 and $1) SHL 1));
    S1 := S1 SHR 1;
    S2 := S2 SHR 1;
  end;
  Result := Format('%.16x%.16x',[T1,T2]);
end;

procedure TgWebCookie.SetValue(const AValue: String);
var
  S1: UInt64;
  S2: UInt64;
  T1: UInt64;
  T2: UInt64;
  Index: Integer;
  Err: Integer;
begin
  if AValue = '' then begin
    FExpire := 0;
    FID := 0;
    exit;
  end;
  Val('$'+Copy(AValue,1,16),T1,Err);
  if Err <> 0 then
    Raise E.CreateFmt('Invalide Cookie %d',[Err]);
  Val('$'+Copy(AValue,17,16),T2,Err);
  if Err <> 0 then
    Raise E.CreateFmt('Invalide Cookie %d',[Err+16]);
  S1 := 0;
  S2 := 0;
  for Index := 0 to 31 do begin
    S1 := (S1 SHL 1) or (T2 AND $1);
    T2 := (T2 SHR 1);
    S2 := (S2 SHL 1) or (T2 AND $1);
    T2 := (T2 SHR 1);
  end;
  for Index := 0 to 31 do begin
    S1 := (S1 SHL 1) or (T1 AND $1);
    T1 := (T1 SHR 1);
    S2 := (S2 SHL 1) or (T1 AND $1);
    T1 := (T1 SHR 1);
  end;
  pUInt64(@FExpire)^ := S1;
  pCardinal(@ID)^ := S2 AND $FFFFFFFF;
  S2 := S2 SHR 32;
  if S2 <> Key then
    raise E.Create('Invalid Cookie Key');
end;

{ TgBase.TEnumerator }

function TgBase.TEnumerator.GetCurrent: TPathValue;
begin
  Result := FItem.GetPathValues(FCurrentIndex);
end;

procedure TgBase.TEnumerator.Init(AItem: TgBase);
begin
  FCount := AItem.GetPathCount;
  FItem := AItem;
  FCurrentIndex := -1;
end;

function TgBase.TEnumerator.MoveNext: Boolean;
begin
  Inc(FCurrentIndex);
  Result := FCurrentIndex < FCount;
end;

{ TgBase.TPathValue }

function TgBase.TPathValue.Empty: Boolean;
begin
  Result := varIsEmpty(Value) or varIsNull(Value) or varIsClear(Value) or (varIsStr(Value) and (Value = ''));
end;

function TgBase.TPathValue.IsClass(AClass: TClass): Boolean;
begin
  Result := Assigned(RTTIProperty) and RTTIProperty.PropertyType.IsInstance and RTTIProperty.PropertyType.AsInstance.MetaclassType.InheritsFrom(AClass)


end;

function TgBase.TPathValue.IsClass(const AClasses: array of TClass): Integer;
var Index: Integer;
begin
  for Index := Low(AClasses) to High(AClasses) do
    if IsClass(AClasses[Index]) then
      exit(Index);
  Result := -1;
end;

function TgBase.TPathValue.IsDefault(ARttiInstanceProperty: TRttiInstanceProperty): Boolean;
begin
  Result := False;
  if not Assigned(ARttiInstanceProperty) then exit;
  case ARttiInstanceProperty.PropertyType.TypeKind of
    tkInteger,tkInt64
    : Result := ARttiInstanceProperty.Default = Value;
  end;
end;

class operator TgBase.TPathValue.Implicit(const Value: TPathValue): Variant;
begin
  Result := Value.Value;
end;

function TgBase.TPathValue.Text: String;
begin
  Result := Path + '=' + Value;
end;

{ MaxTextLength }

constructor MaxTextLength.Create(AMaxLength: Integer; ASize: Integer = -1);
begin
  inherited Create;
  Fmaxlength := AMaxLength;
  Fsize := ASize;

end;

{ HTMLControlAttribute }

constructor HTMLControlAttribute.Create(const AHTML: String);
begin
  inherited Create;
  HTML := AHTML;

end;

{ ValidationRegEx }

procedure ValidationRegEx.Create(const ARegExSearch, ARegExReplacement: String);
begin
  inherited Create;
  RegExSearch := ARegExSearch;
  RegExReplacement := ARegExReplacement;
end;

procedure ValidationRegEx.Execute(AObject: TgObject;
  ARTTIProperty: TRTTIProperty);
begin
{ TODO : Need to setup the regular expression Validation }
end;

{ Caption }

constructor Caption.Create(const AValue: String);
begin
  inherited Create;
  Value := AValue;
end;

{ Help }

constructor Help.Create(const AValue: String);
begin
  inherited Create;
  Value := AValue;
end;

{ FormatFloat }

constructor FormatFloat.Create(const AValue: String);
begin
  inherited Create;
  Value := AValue;
end;


{ HTMLAttribute }

function HTMLAttribute.AsText: String;
begin
  Result := Name+'="'+Value+'"';
end;

constructor HTMLAttribute.Create(const AName: String; const AValue: String);
begin
  inherited Create;
  Name := AName;
  Value := AValue;

end;

{ HTMLText }

constructor HTMLText.Create;
begin
  inherited Create('class','HTMLEditor');
end;

{ LocalFileName }

constructor LocalFileName.Create;
begin
  inherited Create('type','file');
end;

{ WebAddress }

constructor WebAddress.Create;
begin
  inherited Create('type','text');
end;

{ Columns }

constructor Columns.Create(const PropertyNames: String);
begin
  Names := SplitString(PropertyNames,',');
end;

{ TgElement.TObjectRef }

class function TgElement.TObjectRef.New(const AName: String;
  AgBase: TgBase): TObjectRef;
begin
  Result.Name := AName;
  Result.Base := AgBase.Objects[AName];
end;

class function TgElement.TObjectRef.NewValue(const AName: String;
  AgBase: TgBase): TValue;
begin
  Result := TValue.From<TObjectRef>(New(AName,AgBase));
end;

{ TOriginalValues }

procedure TgOriginalValues.Load;
var
  RttiProperties: TArray<TRTTIProperty>;
  RttiInstanceProperty: TRttiInstanceProperty;
  Highest: Integer;
  Source: TgBase;
  Index: Integer;
begin
  Highest := -1;
  Source := Owner;
  RttiProperties := G.AssignableProperties(Source);
  for Index := 0 to High(RttiProperties) do
  begin
    RttiInstanceProperty := RttiProperties[Index] as TRttiInstanceProperty;
    Highest := Max(RttiInstanceProperty.PropInfo.NameIndex,Highest);
  end;
  SetLength(FValues,Highest+1);
  for Index := 0 to High(FValues) do
    FValues[Index] := Null;
  for Index := 0 to High(RttiProperties) do
  begin
    RttiInstanceProperty := RttiProperties[Index] as TRttiInstanceProperty;
    Source.DoGetValues(RttiInstanceProperty,FValues[RttiInstanceProperty.PropInfo^.NameIndex]);
  end;
end;

function TgOriginalValues.DoGetValues(const APath: string;
  out AValue: Variant): Boolean;
var
  Source: TgBase;
  RttiProperty: TRttiProperty;
begin
  if APath = '' then
    Exit(False);
  Source := Owner;
  Result := Assigned(Source) and Source.DoGetProperties(APath,RTTIProperty,Source);
  Result := Result and (RttiProperty is TRttiInstanceProperty);
  if (TRttiInstanceProperty(RttiProperty).PropInfo.NameIndex <= High(FValues)) then
    AValue := FValues[TRttiInstanceProperty(RttiProperty).PropInfo.NameIndex]
  else
    AValue := null;
end;
{ TgPersistenceManager }
function TgPersistenceManager.FileName: String;
begin
  Result := Format('%s%s.xml', [ForClass.PersistenceManagerPath, ForClass.FriendlyName]);
end;

{ TgSerializerXML.THelperDictionary }

class procedure TgSerializerXML.THelperDictionary.DeserializeUnpublishedProperty(
  AObject: TgDictionary; ASerializer: TgSerializerXML;
  const PropertyName: String);
begin
  AObject[PropertyName] := ASerializer.CurrentNode.NodeValue;
end;

class procedure TgSerializerXML.THelperDictionary.Serialize(
  AObject: TgDictionary; ASerializer: TgSerializerXML;
  ARTTIProperty: TRTTIProperty);
var
  Item: TgBase.TPathValue;
begin
  for Item in AObject do
  begin
    if Assigned(Item.RTTIProperty) then
      Inherited Serialize(AObject, ASerializer, Item.RTTIProperty)
    else
      ASerializer.AddValueproperty(Item.Path,Item.Value);
  end;

end;

Initialization
  TgSerializerJSON.Register;
  TgSerializerXML.Register;
  TgSerializerCSV.Register;
  RegisterRuntimeClasses([TgPersistenceManagerFile, TgPersistenceManagerDBXFirebird, TgPersistenceManagerIBX, TgConnectionDescriptorIBX, TgConnectionDescriptorDBXFirebird]);
end.




