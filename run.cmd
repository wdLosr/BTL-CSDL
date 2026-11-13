@echo off
cd /d "%~dp0"
if not exist target\english-center-web-1.0.0.jar (
  echo Chua co file JAR. Hay build du an truoc khi chay.
  exit /b 1
)
java -jar target\english-center-web-1.0.0.jar
