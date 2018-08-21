+++
date = "2018-08-20"
draft = true
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

После установки [августовского релиза Power BI ](https://powerbi.microsoft.com/en-us/blog/power-bi-desktop-august-2018-feature-summary) очень обрадовался увидев поддержку [Python](https://powerbi.microsoft.com/en-us/blog/power-bi-desktop-august-2018-feature-summary/#python). Как раз в работе оказался проект в котором поддержка Python оказывалась подходящей. Нужно было подключатся к API предварительно зашифровывая тело запроса открытым и закрытым ключём перед отправлением запроса к API. К сожалению как оказалось [поддержка шифрования в Power BI](https://blog.crossjoin.co.uk/2017/11/06/which-m-functions-are-only-available-to-custom-data-connectors/) есть только в [кастомных дата коннекторах](https://github.com/Microsoft/DataConnectors) и нет в Power Query для Power BI Desktop. А при всем моем теплом отношении к R связываться с ним лишний раз не хотелось. Поддержке Python в Power BI был рад очень.

## Задача
* Управлять параметрами отчета Power BI поведением скрипта на Python.

## Предварительные требования
1. У вас установлена [Anaconda](https://www.anaconda.com/download/)
1. В Power BI включена [поддержка Python](https://powerbi.microsoft.com/en-us/blog/power-bi-desktop-august-2018-feature-summary/#python)
1. Запустите в терминале `jupyter notebook`
1. Перед глазами есть памятка по [Python](https://github.com/ehmatthes/pcc/releases/download/v1.0.0/beginners_python_cheat_sheet_pcc_all.pdf)

## Решение
* В файле Power BI создаем параметры отчета.
* Оборачиваем параметры отчета в таблицу подходящим для вас видом. Если есть параметры типа `date`/`datetime` предварительно приводим их к строке:

```
let
  Source = Table.FromRows(
    { 
      { 
        Date.ToText( FromDate, "dd.MM.yyyy" ), 
        Date.ToText( ToDate,   "dd.MM.yyyy" ) 
      } 
    },
    type table [ FromDate = text, ToDate = text ] 
  )
in
  Source
```

### Обсуждение решения
* Из описания помощи к функции power query `Python.Execute` видно, что функция получает два параметра `function (script as text, optional arguments as nullable record) as table`. Обязательный `script` собственно текст скрипта на Python и не обязательный `arguments`. Опытным путем понял, что корректным форматом передачи аргументов внутрь скрипта является таблица. Таким образом для передачи аргументов нужно создать запись у которой есть хотя-бы одно значение содержащее таблицу. В нашем случае мы создали запись вида `[ Parameters = Parameters ]`. Где справа ключ записи, а справа ссылка на таблицу содержащую параметры.

* При подготовке примера оказалось что у Power BI при передаче параметров есть особенность работы с типом `date`/`datetime`.
* Дату и время в power query нужно приводить к строке.
* А внутри скрипта на python приводить обратно к типу `date`/`datetime`.


### Результат
* [Решение на Power BI](https://github.com/DmitriyVlasov/Blog/blob/master/samples/2018-08-20/sample-power-bi-use-python-script-with-parameters.pbix)
* [Файл скрипта на python в формате jupiter](https://github.com/DmitriyVlasov/Blog/blob/master/samples/2018-08-20/sample-power-bi-use-python-script-with-parameters.ipynb)
