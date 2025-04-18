@echo off
echo Nettoyage des fichiers de build précédents...
rmdir /s /q build
rmdir /s /q .dart_tool
rmdir /s /q .flutter-plugins
rmdir /s /q .flutter-plugins-dependencies

echo Suppression du fichier pubspec.lock...
del pubspec.lock

echo Récupération des dépendances...
flutter pub get

echo Compilation pour Windows...
flutter build windows --release

echo Compilation terminée!
pause

