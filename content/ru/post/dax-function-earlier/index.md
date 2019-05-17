+++
date = "2017-07-05T11:37:05+03:00"
highlight = true
math = false
tags = ["Power BI","Excel","DAX"]
draft = false
title = "Пример использования функции EARLIER"

[header]
  caption = ""
  image = ""
+++

# Синтаксис
```
EARLIER(column, [number])
```
## Параметры

|Параметр|Обязательный|Описание|
|---|---|---|
|`column`| Да |  Столбец или выражение, результатом которого служит столбец. |
|`number` | Нет | Следующий внешний этап вычисления. По умолчанию 1. |

## Возвращаемое значение
Текущее значение строки из столбца `column` на расстоянии в `number` внешних этапов вычисления.

# Пример
```dax
=
COUNTROWS (
    FILTER (
        ProductSubcategory;
        EARLIER ( ProductSubcategory[TotalSubcategorySales] )
            < ProductSubcategory[TotalSubcategorySales]
    )
)
    + 1
```

1. Функция `EARLIER` получает значение TotalSubcategorySales для текущей строки в таблице. В данном случае, поскольку процесс только начинается, это первая строка в таблице.
1. `EARLIER([TotalSubcategorySales])` дает результат $ 156 176.88 — текущая строка во внешнем цикле.
1. Теперь функция `FILTER` возвращает таблицу, где все строки имеют значение TotalSubcategorySales, превышающее $ 156 176.88 (текущее значение `EARLIER`).
1. Функция `COUNTROWS` подсчитывает строки отфильтрованной таблицы и присваивает новому вычисляемому столбцу в текущей строке полученное значение и прибавляет единицу [^1].
1. Формула вычисляемого столбца переходит к следующей строке, и шаги с 1 по 4 повторяются. Эти шаги повторяются до конца таблицы.
1. Функция `EARLIER` всегда получает значение столбца перед выполнением текущей операции в таблице. Чтобы получить значение на более раннем этапе цикла, установите второй аргумент в значение 2.

[^1]: Прибавлять единицу необходимо, чтобы предотвратить появление [пустого значения](../handing-of-dax-blank) в качестве значения с верхним рангом.