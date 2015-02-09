namespace WeatherIndicator {
    struct Weather {
        string weather_type;
        int temperature;
        string icon;
        bool loaded;
    }

    interface Provider {
        public abstract Weather now();
    }
}
