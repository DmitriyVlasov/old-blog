// This file contains your Data Connector logic
section MangoOfficeVpbx;

////////////////////////////////////////////////////////////////////
//                       Example Usage                            //
////////////////////////////////////////////////////////////////////
//   Source =                                                     //
//     MangoOfficeVpbx.Contents(                                  //
//       #datetime(2018, 1, 1, 0, 0, 0),                          //
//       #datetime(2018, 12, 31, 0, 0, 0),                        //
//       {"start","finish","answer","from_number","to_number"}    //
//     )                                                          //
////////////////////////////////////////////////////////////////////

[ DataSource.Kind="MangoOfficeVpbx", Publish="MangoOfficeVpbx.UI" ]
shared MangoOfficeVpbx.Contents = 
  ( 
    optional dateTimeFrom as datetime, 
    optional dateTimeTo as datetime, 
    optional fields_list as list
  ) => 
  main( dateTimeFrom, dateTimeTo, fields_list );

//
// Mango Office Vpbx Configuration settings
//

credentail = Extension.CurrentCredential();
PUBLIC_KEY = Text.FromBinary( Extension.Contents( "PUBLIC_KEY" ) );
PRIVATE_KEY = Text.FromBinary( Extension.Contents( "PRIVATE_KEY" ) );

DEFAULT_START_TIME = #datetime(2018,1,1,0,0,0);
DEFAULT_END_TIME = #datetime(2018,1,2,0,0,0);

REQUEST_URI = "https://app.mango-office.ru/vpbx/stats/request";
RESULT_URI = "https://app.mango-office.ru/vpbx/stats/result";

FIELDS_DEFAULT = "start,finish,answer,from_extension,from_number,to_extension,to_number,disconnect_reason,line_number,location";

//
// [V] Функция преобразования даты времени в Unixtime
//
DateTime.ToUnixtime = 
  ( dateTime as datetime ) =>
  let 
    startDateTime = #datetime( 1970, 1, 1, 0, 0, 0 ),
    duration = dateTime - startDateTime,
    seconds = Duration.TotalSeconds( duration )
  in
   seconds;

//
// [V] Возвращает Json для POST-запроса по дате начала и дате конца
//
create_query = 
  ( 
    dateTimeFrom as datetime,
    dateTimeTo as datetime,
    optional fields_list as list 
  ) =>
  let
    data = [
      date_from = DateTime.ToUnixtime( dateTimeFrom ),
      date_to = DateTime.ToUnixtime( dateTimeTo ),
      from = [ 
          extension = "", 
          number = "" 
      ],
      to = [ 
          extension = "", 
          number = "" 
      ],
      fields = 
        if fields_list = null 
        then FIELDS_DEFAULT 
        else Text.Combine(fields_list, ",")
    ]
  in
    Json.FromValue( data );



//
// [V] Возвращает sign для запроса по Json
//
create_sign = 
  ( queryJson as any ) =>
  let
    queryText = 
      Text.FromBinary( queryJson ),
    queryWithSignText = 
      Text.ToBinary( PUBLIC_KEY & queryText & PRIVATE_KEY ),
    hash = 
      Crypto.CreateHash( CryptoAlgorithm.SHA256, queryWithSignText ),
    signature = 
      Binary.ToText( hash, BinaryEncoding.Hex )
  in 
    signature;

//
// [V] Отправляет POST и получает ключ
//
send_query_and_get_key = 
  ( 
    dateTimeFrom as datetime,
    dateTimeTo as datetime,
    optional fields_list as list 
  ) =>
  let
    query = 
      create_query( dateTimeFrom, dateTimeTo, fields_list ),
    sign = 
      create_sign( query ),
    content = 
      [
        vpbx_api_key = PUBLIC_KEY,
        sign = sign,
        json = Text.FromBinary( query )
      ],
    api_response = 
      Web.Contents( REQUEST_URI, 
        [
          Headers = [
              #"Content-Type" = "application/x-www-form-urlencoded",
              #"Accept" = "application/json"
          ],
          Content = 
            Text.ToBinary( Uri.BuildQueryString( content ) ),
          ManualStatusHandling = { 404 } 
        ]
      ),
    result = 
      Json.Document( api_response )
    in
      result;

//
// [V] Получает raw-таблицу по запросу
//
get_chunk_data = 
  (
    dateTimeFrom as datetime,
    dateTimeTo as datetime,
    optional fields_list as list
  ) =>
  let
    request = 
      send_query_and_get_key( dateTimeFrom, dateTimeTo, fields_list ),
    request_key = 
      Json.FromValue( request ),
    sign = 
      create_sign( request_key ),
    json = 
      Text.FromBinary( Json.FromValue( request ) ),
    data = 
      [
        vpbx_api_key = PUBLIC_KEY,
        sign = sign,
        json = json
      ],
    headers = 
      [
         #"Content-Type" = "application/x-www-form-urlencoded" 
      ],
    content = 
      Text.ToBinary( Uri.BuildQueryString( data ) ),
    api_result = 
      Web.Contents( RESULT_URI, 
        [
          Headers = headers,
          Content = content,
          IsRetry = true,
          ManualStatusHandling = { 404 }
        ]
      ),
    response = 
      Text.FromBinary( api_result ),
    result = 
      if Value.Metadata( api_result )[ Response.Status ] = 200 then 
        { "200", response  }
      else 
        { "error", "Can't get data for this month" }
  in
    result;

//
// [V] Retry-функция для запроса на сервер
//
Value.WaitFor = 
  (
    producer as function,
    interval as function,
    optional count as number
  ) as any =>
  let
    list = List.Generate(
      () => { 0, producer(0) },
      ( state ) => 
        state{0} < count and 
        ( count = null or state{0} <> null ),
      ( state ) => 
        if state{1}{0} <> "error" 
        then { null, state{1} } 
        else { 1 + state{0}, Function.InvokeAfter( () => producer( state{0} ), interval( state{0} ) ) },
      ( state ) => state{1}{1}
    )
  in
    List.Last( list );
       
//
// [V] Retry-запрос насервер
//
get_chunk_data_with_retry = 
  (
    dateTimeFrom as datetime, 
    dateTimeTo as datetime,
    optional fields_list as list 
  ) =>
  let
    response = 
      get_chunk_data( dateTimeFrom, dateTimeTo, fields_list ),
    waitForResult = 
      if response{0} = "error" then
        Value.WaitFor(
          ( _ ) => get_chunk_data( dateTimeFrom, dateTimeTo, fields_list ),
          ( _ ) => #duration(0, 0, 0, 5),
          10
        )
      else
        response{1}
  in
    waitForResult;
       
total_month = 
  ( _start as datetime, 
    _end as datetime
  ) =>
  let
    year_difference = 
      Date.Year(_end) - Date.Year(_start),
    month_difference = 
      Date.Month(_end) - Date.Month(_start),
    total = 
      month_difference + year_difference*12 + 1
  in
    total,

//
// [V] Возвращает List список стартовых дат по каждому месяцу
//
month_list = 
  ( start as datetime, 
    end as datetime
  ) =>
  let
    result = List.Generate( 
      each [ i = 0, month = start ],
      each [ i] < total_month( start, end ), 
      each [ i = [i] + 1, month = Date.AddMonths( [month], 1 ) ] , 
      each [ month ]
    )
  in
    result;
    
//
// [V] Возвращает список пар промежутков по каждому месяцу
//
month_touple = 
  ( 
    month as date 
  ) =>
  { 
    DateTime.From( month ), 
    DateTime.From( Date.EndOfMonth( month ) ) + #duration(0,23,59,59)
  },

get_periods = 
  ( 
    dateTimeFrom as datetime, 
    dateTimeTo as datetime 
  ) =>
  let
    month_list = 
      month_list( dateTimeFrom, dateTimeTo ),
    length = 
      List.Count( month_list ),
    periods = 
      List.Generate( () => 
        0, 
        each _ < length - 1,
        each _ + 1, 
        each month_touple( DateTime.Date( month_list{_} ) )
    ),
    end_period = 
      {
        { 
          DateTime.From( periods{length - 2}{1} ) + #duration(0,0,0,1), 
          DateTime.From( dateTimeTo ) }
      },
    result = 
      if length > 1 
        then List.Combine( { periods, end_period } )
      else
        { { dateTimeFrom, dateTimeTo } }      
  in
    result;

//
// [V] Получает полную информацию за все промежутки 
//
main =  
  (
    dateTimeFrom as nullable datetime,
    dateTimeTo as nullable datetime,
    optional fields_list as list
  ) =>
  let
    time_from = 
      if dateTimeFrom = null 
      then DEFAULT_START_TIME 
      else dateTimeFrom,
    time_to = 
      if dateTimeTo = null 
      then DEFAULT_END_TIME 
      else dateTimeTo,
    month_periods_list = 
      get_periods( time_from, time_to ),
    lenght = 
      List.Count( month_periods_list ),
    chunk_data = List.Generate( 
      each 0, 
      each _ < lenght, 
      each _ + 1, 
      each 
        {  
          Function.InvokeAfter( () =>
            get_chunk_data_with_retry( 
              month_periods_list{_}{0}, 
              month_periods_list{_}{1}, 
              fields_list 
            ), 
            #duration(0,0,0,0)
          )
        } 
      ),
      text_data = 
        Text.Combine( List.Combine( chunk_data ), "#(cr)" ),
      prepared_data = 
        Text.Replace( text_data, ";", "," ),
      result = 
        Table.PromoteHeaders(
          Csv.Document(
            ( if fields_list = null 
              then FIELDS_DEFAULT 
              else Text.Combine( fields_list, "," ) 
            ) & "#(cr)" & prepared_data
          )
        )
    in
      result;
//
// Data Source Kind description
//
MangoOfficeVpbx = [
  TestConnection = ( dataSourcePath ) => { "MangoOfficeVpbx.Contents" },
  Authentication = [
    Implicit = []
  ],
  Label = Extension.LoadString( "DataSourceLabel" )
];

//
// UI Export definition
//
MangoOfficeVpbx.UI = [
  ButtonText = { 
    Extension.LoadString("ButtonTitle"), 
    Extension.LoadString("ButtonHelp") 
  },
  Category = "Other",
  Beta = true,
  LearnMoreUrl = "https://powerbi.microsoft.com/",
  SupportDirectQuery = false,
  SourceImage = MangoOfficeVpbx.Icons,
  SourceTypeImage = MangoOfficeVpbx.Icons
];

MangoOfficeVpbx.Icons = [
  Icon16 = { 
    Extension.Contents("MangoOfficeVpbx16.png"), 
    Extension.Contents("MangoOfficeVpbx20.png"), 
    Extension.Contents("MangoOfficeVpbx24.png"), 
    Extension.Contents("MangoOfficeVpbx32.png") 
  },

  Icon32 = { 
    Extension.Contents("MangoOfficeVpbx32.png"), 
    Extension.Contents("MangoOfficeVpbx40.png"), 
    Extension.Contents("MangoOfficeVpbx48.png"), 
    Extension.Contents("MangoOfficeVpbx64.png") 
  }
];