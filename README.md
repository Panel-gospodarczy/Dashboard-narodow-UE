DOKUMENTACJA APLIKACJI „DASHBOARD BOGACTWA KRAJÓW UNII EUROPEJSKIEJ”

Klaudia Dobrowolska 276 174, Sebastian Dziadko 275 323
Aplikacja dostępna pod linkiem: https://sdziadko.shinyapps.io/bogactwo-narodow/
**Charakterystyka oprogramowania**

Nazwa skrócona:

BOGACTWO NARODÓW

Nazwa pełna:

DASHBOARD BOGACTWA NARODÓW UNII EUROPEJSKIEJ

Opis:

Aplikacja to narzędzie edukacyjno-poznawcze, stworzone z myślą o użytkownikach na różnych poziomach zaawansowania w pracy z danymi. Pobiera ona dane dotyczące trzynastu wybranych wskaźników gospodarczych\*, bezpośrednio z Eurostatu, co gwarantuje aktualność i wiarygodność danych. Na podstawie tych danych generowane są szczegółowe tabele i wykresy, umożliwiające użytkownikom analizę. Dodatkowo, dane te służą do stworzenia, na podstawie wiedzy eksperckiej, wskaźnika kompozytowego, umożliwiającego porządkowanie krajów według ich bogactwa, za pomocą rankingu. Interaktywna mapa w łatwy i przejrzysty sposób dostarcza informacji o poszczególnych krajach.

**Prawa autorskie**

Niniejszy dokument, dotyczący praw autorskich aplikacji „BOGACTWO NARODÓW”, powstał w celu ochrony praw własności intelektualnej właścicieli aplikacji oraz zapewnienia zgodności z obowiązującymi przepisami prawnymi.

1. PRAWA AUTORSKIE I WŁASNOŚĆ INTELEKTUALNA


1.1 Właściciel praw autorskich

Aplikacja „BOGACTWO NARODÓW”, w tym jej kod źródłowy, interfejs użytkownika, dokumentacja i inne elementy powiązane, jest udostępniana na licencji Creative Commons Attribution-NonCommercial-ShareAlike 4.0 (CC BY-NC-SA 4.0). Autorami są KLAUDIA DOBROWOLSKA i SEBASTIAN DZIADKO.

   1.2 Licencja użytkowania

Licencja użytkowania Aplikacja jest dostępna dla każdego na zasadach:

• Swobodnego kopiowania, modyfikowania i rozpowszechniania, przy zachowaniu uznania autorstwa i tej samej licencji.

• Wyłącznie do użytku niekomercyjnego.

• Możliwości tworzenia projektów pochodnych, które muszą być udostępniane na tych samych zasadach.

   1.3 Dane

Dane gospodarcze wykorzystywane w aplikacji pochodzą z zewnętrznego źródła, jakim jest Eurostat. Dane te nie są objęte własnymi prawami autorskimi.

   1.4 Materiały graficzne

Elementy graficzne, takie jak mapy, wykresy i tabele, mogą być wykorzystywane, modyfikowane i udostępniane, z zachowaniem uznania autorstwa i wyłącznie  
w celach niekomercyjnych.

2. OGRANICZENIA I ZAKAZY

2.1 Kopiowanie i dystrybucja

Dozwolone jest kopiowanie, dystrybucja i udostępnianie aplikacji zgodnie  
z warunkami licencji CC BY-NC-SA 4.0.

   2.2. Modyfikacje

Modyfikacje aplikacji są dozwolone, pod warunkiem zachowania zgodności z licencją oraz uznania autorstwa.

   2.3. Wykorzystanie w celach komercyjnych

Wykorzystywanie aplikacji w celach komercyjnych jest niedozwolone. Wszelkie wyjątki wymagają zawarcia odrębnej umowy z autorami.

3. NARUSZENIA PRAW AUTORSKICH

W przypadku naruszenia praw autorskich, właściciele zastrzegają sobie prawo do podjęcia odpowiednich kroków prawnych, w tym dochodzenia roszczeń odszkodowawczych i żądania zaprzestania działań naruszających prawa autorskie.

**Specyfikacja wymagań**

| **Identyfikator** | **Nazwa** | **Opis** | **Priorytet\*** | **Kategoria** |
| --- | --- | --- | --- | --- |
| P1  | Współpraca  <br>z bazą danych Eurostat | Pobieranie danych gospodarczych  <br>z Eurostatu. | 1   | Funkcjonalne |
| P2  | Mapa krajów UE | Wyświetlanie interaktywnej mapy z podziałem na kraje UE. | 1   | Funkcjonalne |
| P3  | Ranking narodów | Ranking prezentujący bogactwo narodów według wskaźnika kompozytowego. | 1   | Funkcjonalne |
| P4  | Wskaźniki gospodarcze | Podsumowanie wskaźników gospodarczych z podziałem na kraje. | 1   | Funkcjonalne |
| P5  | Wykresy | Wykresy wskaźników gospodarczych  <br>z podziałem na kraje. | 1   | Funkcjonalne |
| P6  | Mapa wskaźnika kompozytowego | Wyświetlenie mapy pokazującej wartość wskaźnika kompozytowego dla krajów. | 1   | Funkcjonalne |
| P7  | Dobór wag wskaźników przez użytkownika | Suwak pozwalający na samodzielny dobór wag przez użytkownika z uwzględnieniem normalizacji danych. | 2   | Funkcjonalne |
| P8  | Powtarzalność | Każde uruchomienie kodu powinno prowadzić do tego samego wyniku (poza rankingiem kompozytowym). | 1   | Niefunkcjonalne |
| P9  | Łatwość obsługi | Intuicyjny interfejs aplikacji. | 1   | Niefunkcjonalne |
| P10 | Niezawodność | System wykonuje polecenia  <br>w sposób przewidywalny  <br>i bezawaryjny. | 1   | Niefunkcjonalne |
| P11 | Zgodność  <br>z przepisami  <br>o danych publicznych | Aplikacja przestrzega przepisów  <br>o udostępnianiu danych publicznych, takich jak otwarte dane. | 1   | Niefunkcjonalne |
| P12 | Kompatybilność | Aplikacja działa  <br>w popularnych przeglądarkach internetowych (Chrome, Edge, Firefox, Safari). | 2   | Niefunkcjonalne |
| P13 | Użyteczność | System niesie za sobą wartość poznawczą  <br>i edukacyjną. | 2   | Niefunkcjonalne |
| P14 | Kolory interfejsu | Aplikacja wykorzystuje odpowiednią paletę kolorów. | 3   | Niefunkcjonalne |

\* 1 – wymagane; 2 – przydatne; 3 – opcjonalne

**Architektura systemu/oprogramowania**

Architektura rozwoju

| **Nazwa** | **Przeznaczenie** | **Wersja** |
| --- | --- | --- |
| R   | Główny język programowania do analizy danych  <br>i wizualizacji. | 4.3.1 |
| Rstudio | Środowisko programistyczne dla języka R. | 2023.09.1 |
| Shiny | Biblioteka do tworzenia interaktywnych aplikacji webowych. | 1.7.5 |
| Leaflet | Tworzenie interaktywnych map. | 2.1.2 |
| Plotly | Tworzenie wykresów i wizualizacji danych. | 3.4.4 |
| dplyr | Manipulacja i przetwarzanie danych. | 1.1.4 |
| DT  | Tworzenie interaktywnych tabel. | 0.27 |
| eurostat | Pobieranie danych statystycznych z Eurostatu. | 3.8.4 |

Architektura uruchomienia

| **Nazwa** | **Przeznaczenie** | **Wersja** |
| --- | --- | --- |
| R   | Uruchamianie aplikacji oraz analizy danych. | 4.3.1 |
| Rstudio | Środowisko do uruchamiania aplikacji. | 2023.09.1 |
| Shiny | Hosting aplikacji webowej Shiny. | 1.7.5 |
| Leaflet | Interaktywne mapy. | 2.1.2 |
| Plotly | Generowanie wizualizacji danych. | 3.4.4 |
| dplyr | Obsługa danych. | 1.1.4 |
| DT  | Prezentacja danych w formie tabel. | 0.27 |
| eurostat | Pobieranie danych statystycznych z Eurostatu. | 3.8.4 |
| Przeglądarka internetowa | Wyświetlanie aplikacji. | najnowsza |

**Testy**

Scenariusze testów

| **Identyfikator** | **Opis testu** | **Oczekiwany wynik** | **ID wymagań** |
| --- | --- | --- | --- |
| T1  | Uruchomienie aplikacji. | Aplikacja uruchamia się bez błędów i wyświetla mapę krajów UE. | P1, P2 |
| T2  | Kliknięcie na mapie Europy  <br>i wyświetlenie wartości wskaźnika dla wybranego kraju. | Po kliknięciu na kraj pojawia się informacja o wartości wskaźnika. | P2, P4, P14 |
| T3  | Zmiana wskaźnika w rozwijanej liście. | Dane na mapie oraz szczegóły  <br>w zakładkach zmieniają się odpowiednio. | P4, P9 |
| T4  | Wyświetlenie rankingu krajów według wskaźnika kompozytowego. | Ranking jest poprawnie wyświetlany w zakładce „Ranking kompozytowy”. | P3  |
| T5  | Wyświetlenie wykresów danych gospodarczych w zakładce „Szczegóły”. | Wykresy pokazują poprawne dane w podziale na państwa. | P4, P5 |
| T6  | Manipulacja wagami wskaźników przez użytkownika w zakładce „Ranking kompozytowy”. | Po zmianie wag wartości wskaźnika kompozytowego oraz ranking krajów aktualizują się dynamicznie i normalizują. | P7  |
| T7  | Wyświetlenie mapy krajów  <br>z wartościami wskaźnika kompozytowego. | Po kliknięciu na kraj pojawia się informacja o wartości wskaźnika kompozytowego. | P6  |
| T8  | Sprawdzenie kompatybilności  <br>w różnych przeglądarkach. | Aplikacja działa poprawnie  <br>w Chrome, Firefox, Safari i Edge. | P12 |
| T9  | Test powtarzalności. | Każde uruchomienie kodu powinno prowadzić do tego samego wyniku. | P8  |

Sprawozdanie z wykonania scenariuszy testów

| **Identyfikator** | **Opis testu** | **Oczekiwany wynik** |
| --- | --- | --- |
| T1  | Sukces | Aplikacja uruchomiła się poprawnie. |
| T2  | Sukces | Kliknięcie na mapie wyświetla poprawne dane wskaźnika. |
| T3  | Sukces | Dane aktualizują się odpowiednio po zmianie wskaźnika. |
| T4  | Sukces | Ranking krajów wyświetla poprawne dane na podstawie wskaźnika kompozytowego. |
| T5  | Sukces | Wykresy w zakładce „Szczegóły” pokazują poprawne dane. |
| T6  | Sukces | Zmiana wag wskaźników działa dynamicznie i bez błędów. |
| T7  | Sukces | Mapa krajów wyświetla poprawne dane na podstawie wskaźnika kompozytowego. |
| T8  | Sukces | Aplikacja działa poprawnie we wszystkich testowanych przeglądarkach. |
| T9  | Sukces | Każde uruchomienie kodu prowadzi do tego samego wyniku. |
