public with sharing class tempClass {
    public static String gValue='';
    public tempClass() {

    }
    public tempClass(String value){
        System.debug('constructor: '+value);
        gValue = value;
    }
    public static void method1(){
        System.debug('static value: '+gValue);
    }
    public void method2(){
        System.debug('non static value: '+gValue);
    }
}