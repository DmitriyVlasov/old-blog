---
title: Power BI and Mongodb
linktitle: Power BI and Mongodb
toc: true
type: docs
date: "2020-02-17T00:00:00+01:00"
draft: false

tags: [ "study area", "область исследования", "power bi", "mongodb", "dremio" ]
menu:
  memo:
    parent: Заметки
    weight: 2

# Prev/next pager order (if `docs_section_pager` enabled in `params.toml`)
weight: 1
---

## Как загрузить данные в Power BI из MongoDB?

{{% alert info %}}
Все ниже следующие выкладки результаты исследование в интернете требуют моделирования и проработки и проверки в рамках конкретных задач проекта.
{{% /alert %}}

### Использовать MongoDB Connector for Business Intelligence

* **Преимущества**: работает из коробки
* **Особенности**: стоит существенных денег
* Позволяет использовать выбранный инструмент BI (Power BI, Tableau, Qlik и другие ) для визуализации, обнаружения и представления отчетов по данным MongoDB с помощью стандартных SQL-запросов.
* Он может использоваться в рамках платной подписки "MongoDB Enterprise Advanced subscription". Стоимость уточняется отдельно у поставщика.
* возможности смотри подробнее на странице: [MongoDB Connector for Business Intelligence](https://www.mongodb.com/products/bi-connector)

### Использовать Dremio

* **Преимущества**: Проект с открытым исходным кодом, Есть сертифицированный коннектор в Power BI (см. статью [Announcing General Availability of Custom and Certified Connectors for Power BI](https://powerbi.microsoft.com/ru-ru/blog/announcing-general-availability-of-custom-and-certified-connectors-for-power-bi/))
* **Особенности**: [Dremio](https://www.dremio.com/) Проект молодой, Дополнительный узел интеграции.
