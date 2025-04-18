@echo off
echo Nettoyage des fichiers de build précédents...
rmdir /s /q build

echo Configuration de l'environnement pour Windows...
flutter config --enable-windows-desktop

echo Récupération des dépendances...
flutter pub get

echo Compilation pour Windows...
flutter build windows --release

echo Compilation terminée!
pause

