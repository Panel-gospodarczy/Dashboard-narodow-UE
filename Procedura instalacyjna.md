1.	Instalacja środowiska
1.1.	Instalacja języka R
Pobierz instalator dla języka R w wersji 4.3.1 z oficjalnej strony: https://cran.r-project.org/.
Zainstaluj język R, postępując zgodnie z instrukcjami instalatora.
1.2.	Instalacja RStudio
Pobierz odpowiednią wersję środowiska RStudio (2023.09.1) z oficjalnej strony: https://posit.co/products/open-source/rstudio/.
Zainstaluj RStudio, postępując zgodnie z instrukcjami instalatora.
2.	Przygotowanie aplikacji
2.1.	Pobranie kodu aplikacji
Pobierz pliki aplikacji z repozytorium GitHub
Upewnij się, że pliki aplikacji są zapisane w dedykowanym folderze na komputerze.
2.2.	Ustawienie folderu roboczego
W RStudio otwórz menu „Session” → „Set Working Directory” → „Choose Directory”.
Wskaż folder, w którym znajdują się pliki aplikacji.
3.	Uruchamianie aplikacji
3.1.	Otwieranie aplikacji
Otwórz RStudio. 
Następnie rozwiń „File”, wybierz „Open File” i wskaż plik aplikacji (np. app.R).
Upewnij się, że wszystkie wymagane pliki znajdują się w jednym miejscu.
3.2.	Instalacja pakietów R
Wpisz poniższe polecenie w konsoli R, aby zainstalować wszystkie wymagane pakiety: „install.packages(c("shiny", "leaflet", "plotly", "dplyr", "DT", "eurostat"))”.
3.3.	Uruchamianie aplikacji w RStudio
Uruchom kod klikając „Run App” w prawym górnym rogu konsoli. 
3.4.	Wyświetlanie aplikacji
Aplikacja otworzy się w środowisku RStudio.
Aplikację otworzyć można także w domyślnej przeglądarce internetowej klikając „Open in Browser”.
Jeśli aplikacja nie otworzy się automatycznie, skopiuj i wklej adres URL wyświetlony w konsoli R do przeglądarki,

4.	Użytkowanie aplikacji
Po uruchomieniu aplikacji użytkownik może korzystać z jej funkcji: interaktywne mapy, wykresy i wizualizacje, tabele
5.	Zakończenie pracy z aplikacją
Zamknij przeglądarkę/RStudio.
6.	Rozwiązywanie problemów
Brakujące pakiety - Upewnij się, że wszystkie wymagane pakiety zostały poprawnie zainstalowane.
Problemy z przeglądarką - Sprawdź, czy przeglądarka jest zaktualizowana do najnowszej wersji oraz czy nastąpiło poprawne połączenie z siecią. 
Błędy w działaniu aplikacji - Skonsultuj się z twórcą aplikacji.

Najprostszy sposób na dostęp do aplikacji: Można otworzyć ją bezpośrednio przez link: https://sdziadko.shinyapps.io/bogactwo-narodow/
