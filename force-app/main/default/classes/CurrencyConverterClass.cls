public with sharing class CurrencyConverterClass {
    public CurrencyConverterClass() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.exchangeratesapi.io/letest');
        request.setHeader('Authorization', '');
    }
}