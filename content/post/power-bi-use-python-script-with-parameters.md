+++
date = "2018-08-20"
draft = false
math = false
highlight = true
tags = ["Power BI","Python"]
title = "Передача Параметров из Power BI в скрипт на Python"
# Optional featured image (relative to `static/img/` folder).
[header]
image = ""
caption = ""

+++
## Предисловие

После установки [августовского релиза Power BI ](https://powerbi.microsoft.com/en-us/blog/power-bi-desktop-august-2018-feature-summary) я очень обрадовался, увидев поддержку [Python](https://powerbi.microsoft.com/en-us/blog/power-bi-desktop-august-2018-feature-summary/#python). Как раз в работе оказался проект, в котором возможность поддержки Python помогла реализовать требования заказчика. Нужно было подключаться к API, предварительно зашифровывая тело запроса открытым и закрытым ключём, перед отправлением запроса к API. К сожалению, как оказалось, [поддержка шифрования в Power BI](https://blog.crossjoin.co.uk/2017/11/06/which-m-functions-are-only-available-to-custom-data-connectors/) есть только в [кастомных дата коннекторах](https://github.com/Microsoft/DataConnectors), и отсутствует в Power Query для Power BI Desktop. А при всем моем теплом отношении к языку R, связываться с ним лишний раз, мне бы не хотелось. Поэтому поддержке Python в Power BI я был рад очень.

## Задача
* Настроить управление поведением скрипта на Python через параметры отчета Power BI Desktop.


## Демонстрационный отчет в Power BI Online
<iframe width="800" height="600" src="https://app.powerbi.com/view?r=eyJrIjoiNDNkZWM5OTgtZjRkMS00YzVkLTkxYjAtYjdmZDA2NzQ0YjdjIiwidCI6IjcyMTYyZmFhLWM0ZDMtNGVkNi04OWJkLWEzNzY0MjE3MDA2MyIsImMiOjl9" frameborder="0" allowFullScreen="true"></iframe>

## Описание решения
### Предварительные требования
1. У вас установлена [Anaconda](https://www.anaconda.com/download/)
1. В Power BI включена [поддержка Python](https://powerbi.microsoft.com/en-us/blog/power-bi-desktop-august-2018-feature-summary/#python)
1. Запуск в терминале `jupyter notebook`
1. Откройте перед глазами памятку по [Python](https://github.com/ehmatthes/pcc/releases/download/v1.0.0/beginners_python_cheat_sheet_pcc_all.pdf)

### Подготовка в Power BI
* В файле Power BI создаем параметры отчета.
* Оборачиваем параметры отчета в таблицу с необходимой структурой. Если используются параметры типа `date`/`datetime`, то предварительно их приводим к строке:

```
let
  Parameters = Table.FromRows(
    { 
      { 
        Date.ToText( FromDate, "dd.MM.yyyy" ), 
        Date.ToText( ToDate,   "dd.MM.yyyy" ) 
      } 
    },
    type table [ FromDate = text, ToDate = text ] 
  )
in
  Parameters
```

### Разработка скрипта Python

В моем примере скрипт на Python будем разрабатывать в инструменте, популярном у аналитиков данных [Jupyter Notebook](http://jupyter.org/). 
 
* Создаем файл блокнота.
* Импортируем библиотеку работы с таблицами Pandas (структура аналогичная объекту Table в Power BI)

```python
import pandas as pd
```

* Объявляем переменную `Parameters` повторяющую структуру, таблицы с параметрами на Power Query (см. выше), это необходимо для отладки и проверки работоспособности скрипта.

```python
import pandas as pd

FromDate = "01.07.2018"
ToDate = "31.07.2018"

Parameters = pd.DataFrame(
    [ 
      [ 
        FromDate, ToDate 
      ] 
    ],
    columns = ['FromDate','ToDate'] 
)
```
> В рамках рассмотренного примера для простоты работы внутри скрипта на Python вручную создается таблица, а затем с помощью переданных параметров таблица отфильтровывается. Полученный результат далее возвращается в Power BI и может использоваться для дальнейшего анализа.

* Далее реализовываем логику обработки скрипта.
* Для удобства переноса разработанного скрипта, обработки снова объявляем импорт библиотеки Pandas.

```python
import pandas as pd
```

* Помним о том, что мы передали параметры в формате даты времени в текстовом формате ( объяснение подробнее [см ниже](#Обсуждение-решения) )


```python
Parameters['FromDate'] = pd.to_datetime( Parameters['FromDate'], format="%d.%m.%Y" )
Parameters['ToDate'] = pd.to_datetime( Parameters['ToDate'], format="%d.%m.%Y" )
```

> Если вам нужно адаптировать параметры под ваш форматы даты времени, можете для информации использовать таблицу кодов форматов для [2](https://docs.python.org/2/library/datetime.html#strftime-and-strptime-behavior) или [3](https://docs.python.org/3/library/datetime.html#strftime-and-strptime-behavior) Питона соответственно.


* Получаем данные из внешней системы. Для демо примера создаем вручную таблицу в Pandas 

```python
Sales = pd.DataFrame( [
        ["01.07.2018", 10], 
        ["01.08.2018", 20], 
        ["01.09.2018", 30]
    ], columns=['Date', 'Amount' ] 
)
```

* Для корректной работы сортировки и фильтрации данных по столбцу даты времени приводим, в исследуемых таблицах столбец к дате.   

```python
Sales['Date'] = pd.to_datetime(Sales['Date'],format="%d.%m.%Y")
```

* Применяем бизнес правила полученные от клиента и параметры, полученные из Power BI, к полученной в скрипте таблице

```python
Result = Sales[ Sales['Date'] > Parameters['FromDate'][0] ]
```

* Средствами [Jupyter Notebook](http://jupyter.org/) мы можем отладить и проверить полученные данные перед копированием полученного сприпта в Power BI. 

* В результате получаем скрипт, подготовленный для передачи в Power BI

```python
# Импортируем библиотеку работы с таблицами Pandas 
import pandas as pd

# Готовим параметры для использования
# Так как параметры даты, времени внутрь Python из Power BI передаются не совсем корректно (с ошибкой).
# Удобно параметры даты передать в строковом виде, а затем привести обрратно в дате.
Parameters['FromDate'] = pd.to_datetime( Parameters['FromDate'], format="%d.%m.%Y" )
Parameters['ToDate'] = pd.to_datetime( Parameters['ToDate'], format="%d.%m.%Y" )

# Получаем данные из внешней системы. Для демо примера просто создаем вручную таблицу в Pandas 
Sales = pd.DataFrame( [
        ["01.07.2018", 10], 
        ["01.08.2018", 20], 
        ["01.09.2018", 30]
    ], columns=['Date', 'Amount' ] 
)
Sales['Date'] = pd.to_datetime(Sales['Date'],format="%d.%m.%Y")

# Применяем бизнес правила и параметры полученные из Power BI к таблице и возвращаем результат
Result = Sales[ Sales['Date'] > Parameters['FromDate'][0] ]
```

### Вызов скрипта на Python из Power BI

* Так как, на данный момент, в мастере создания скрипта на Python в Power BI нет возможности передать не обязательные параметры, для простоты создаем минимально рабочий пример для создания корректного запроса Power Query, который затем обновим разработанным выше скриптом.

```python
import pandas as pd

Dummy = pd.DataFrame( [ [ "" ] ], columns = ['Dummy'] )

```
* В мастере создания запросов Power BI Desktop, выбираем из раскрывающегося списка скрипт на Python. Передам минимальный скрипт на Python написанный выше.
* В мастере выбираем флажком таблицу `Dummy` и нажимаем OK.
* Скрипт будет успешно создан.
* Для передачи параметров нам придется перейти в расширенный редактор Power Query, где мы увидим следующий текст:

```
let
    Source = Python.Execute("import pandas as pd#(lf)#(lf)Dummy = pd.DataFrame( [ [ """" ] ], columns = ['Dummy'] )#(lf)"),
    Dummy1 = Source{[Name="Dummy"]}[Value]
in
    Dummy1
```

* Последний шаг навигации нам пока что не нужен, уберем его.

```
let
    Source = Python.Execute("import pandas as pd#(lf)#(lf)Dummy = pd.DataFrame( [ [ """" ] ], columns = ['Dummy'] )#(lf)")
in
    Source
```

* Передадим параметры из Power Query в пустой скрипт. С помощью ручного редактирования в расширенном редакторе Power Query добавим второй параметр вида `[ Parameters = Parameters ]`.
* В результате получится следующий запроса на Power Query:

```
let
    Source = Python.Execute("import pandas as pd#(lf)#(lf)Dummy = pd.DataFrame( [ [ """" ] ], columns = ['Dummy'] )#(lf)", [ Parameters = Parameters ])
in
    Source
```

* Power Query предупредит что мы изменили определение скрипта. Мы должны согласиться с изменениями. В результате нам будет доступно для навигации две записи каждая из которых содержит таблицу.
* Отредактируем с помощью мастера запрос и вставим разработанный на предыдущем шаге скрипт, нажав на шестеренку напросив пункта Source.
* В результате получится следующий запроса на Power Query:

```
let
  Source = Python.Execute("import pandas as pd#(lf)import datetime as dt#(lf)#(lf)Parameters['FromDate'] = pd.to_datetime( Parameters['FromDate'], format=""%d.%m.%Y"" )#(lf)Parameters['ToDate'] = pd.to_datetime( Parameters['ToDate'], format=""%d.%m.%Y"" )#(lf)#(lf)Sales = pd.DataFrame( [#(lf)        [dt.date(2018,7,1), 10], #(lf)        [dt.date(2018,8,1), 20], #(lf)        [dt.date(2018,9,1), 30]#(lf)    ], columns=['Date', 'Amount' ] #(lf))#(lf)#(lf)Sales['Date'] = pd.to_datetime(Sales['Date'])#(lf)#(lf)Result = Sales[ Sales['Date'] > Parameters['FromDate'][0] ]",[ Parameters = Parameters ])
in
    Source
```

> Обратите внимание на то, что все наше красивое форматирование в python Power BI Desktop собрал в одну строку. Так что если далее потребуется дорабатывать наш скрипт мы вернемся в Jupyter и последовательно проделаем шаги: исправим, отладим и так же передадим его через буфер обмена в Power BI Desktop.

* В результате у нас будет доступны все источники данных в формате `DataFrame` которые мы объявили в скрипте и далее средствами Power Query как мы привыкли будем обрабатывать таблицы и объединять их в модель.

### Материалы

Для удобства исследования статьи привожу готовый файл срипта и пример на Power BI:

* [Решение на Power BI](https://github.com/DmitriyVlasov/Blog/blob/master/samples/2018-08-20/sample-power-bi-use-python-script-with-parameters.pbix)
* [Файл скрипта на python в формате jupiter](https://github.com/DmitriyVlasov/Blog/blob/master/samples/2018-08-20/sample-power-bi-use-python-script-with-parameters.ipynb)
* [Ссылка на интерактивный отчет в Power BI online](https://app.powerbi.com/view?r=eyJrIjoiNDNkZWM5OTgtZjRkMS00YzVkLTkxYjAtYjdmZDA2NzQ0YjdjIiwidCI6IjcyMTYyZmFhLWM0ZDMtNGVkNi04OWJkLWEzNzY0MjE3MDA2MyIsImMiOjl9)

### Обсуждение решения
* Из описания помощи к функции power query `Python.Execute` видно, что функция получает два параметра `function (script as text, optional arguments as nullable record) as table`. Обязательный `script` собственно текст скрипта на Python и не обязательный `arguments`. Опытным путем понял, что корректным форматом передачи аргументов внутрь скрипта является таблица. Таким образом для передачи аргументов нужно создать запись у которой есть хотя-бы одно значение содержащее таблицу. В нашем случае мы создали запись вида `[ Parameters = Parameters ]`. Где справа ключ записи, а справа ссылка на таблицу содержащую параметры.
* При подготовке примера оказалось что у Power BI при передаче параметров есть особенность работы с типом `date`/`datetime`.
* Дату и время в power query нужно приводить к строке.
* А внутри скрипта на python приводить обратно к типу `date`/`datetime`.