# Приложение для автоматического создания групп сборщиков данных со счетчиками производительности из шаблонов

---

### __Алгоритм работы приложения__


1. Запустить от имени администратора файл import.ps1.bat

2. Ввести следующие параметры: общую длительность (Duration), интервал выборки (Sample interval), путь к папке с шаблонами (Templates Path).

3. Нажать кнопку "Импорт" для импорта групп сборщиков данных в Perfmon.

4. Нажать кнопу "Старт" для запуска этих групп.

В случае необходимости досрочной остановки работы групп сборщиков данных нажать кнопку "Стоп".

Для удаления групп сборщиков данных из Perfmon нажать кнопку "Удалить". В дальнейшем с помощью кнопки "Импорт" можно их повторно импортировать.

---

### __Создание шаблонов групп сборщиков данных__


Группы сборщиков данных создаются на основе шаблонов. Примеры шаблонов находятся в папке Templates в корне проекта.

Шаблоны - файлы формата *.xml с определенной структурой. 

Ключевыми являются следующие параметры:

- __<?xml version="1.0" encoding="UTF-8"?>__ - файл шаблона должен иметь кодировку UTF-8 без BOM.

- __Duration__ - общая длительность работы группы сборщиков данных. Задается программно, в шаблоне должна быть представлена в виде \<Duration\>#####\</Duration\>.

- __DisplayName__ и __Description__ - отображаемое имя и описание группы.

- __OutputLocation__ - путь для сохранения групп сборщиков данных. Первая часть должна совпадать со значением параметра RootPath.

- __RootPath__ - корневой путь. Рекомендуется использовать значение "%systemdrive%\PerfLogs\Admin".

- __SubdirectoryFormat__ и __SubdirectoryFormatPattern__ - формат названия папки группы. Название конечной папки из OutputLocation должно соответствовать этому формату. Рекомендуется использовать значения "3" и "yyyyMMdd\_HHmm" соответственно.

- __UserAccount__ - имя пользователя.
		
- __PerformanceCounterDataCollector__ - блок, отвечающий за параметры конкретного сборщика данных. Таких блоков может быть несколько, если необходимо использовать один и тот же сборщик с разными параметрами. 

    Из важных полей данного блока можно перечислить следующие:

	* __Name__ - отображаемое имя сборщика данных в Perfmon.
		
	* __FileName__ - имя файла лога сборщика на жестком диске. Задается без расширения (оно указывается в LogFileFormat).
		
	* __SampleInterval__ - интервал выборки. Задается программно, в шаблоне должен быть представлен в виде \<SampleInterval\>#####\</SampleInterval\>.
		
	* __LogFileFormat__ - формат файла лога сборщика на жестком диске. Допустимые значения: 0 - csv, 1 - tsv, 2 - sql, 3 - blg (двоичный).
		
	* __Counter__ - название счетчика производительности, входящего в сборщик данных (напр., "\Memory\% Committed Bytes In Use"). Допустимо использовать названия счетчиков на английском языке и на родной локали системы. Полей Counter может быть несколько для разных счетчиков (но не рекомендуется включать большое количество счетчиков в один сборщик во избежание проблем с производительностью).

	* __DataManager__ - опциональный блок, необходимый для создания отчета об ощибках работы группы сборщиков данных. Ключевые поля:

	* __Enabled__ - для создания отчета выставить значение "1".
		
	* __ReportFileName__ и __RuleTargetFileName__ - названия файла отчета.

В дальнейшем (после импорта шаблонов) значения параметров сборщиков данных можно будет изменить в Perfmon'е.
