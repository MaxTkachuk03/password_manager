#!/bin/bash

DEVICE_SELECTION=$1

case $DEVICE_SELECTION in
    "android")
        echo "🚀 Запускаю Android емулятор..."
        flutter emulators --launch Pixel_8_API_35 &
        EMULATOR_PID=$!
        echo "⏳ Чекаю поки емулятор запуститься..."
        sleep 20
        echo "✅ Android емулятор готовий"
        ;;
    "ios")
        echo "🚀 Запускаю iOS симулятор..."
        flutter emulators --launch apple_ios_simulator
        sleep 10
        echo "✅ iOS симулятор готовий"
        ;;
    "active")
        echo "📱 Використовую активний пристрій"
        ;;
    *)
        echo "📱 Використовую активний пристрій (за замовчуванням)"
        ;;
esac
