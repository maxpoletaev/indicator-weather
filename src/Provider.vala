namespace WeatherIndicator {
    struct Weather {
        string weather_type;
        int temperature;
        bool loaded;
    }

    interface Provider {
        public abstract Weather now();
    }
}
