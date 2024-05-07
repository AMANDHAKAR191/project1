@isTest
private class RandomContactFactoryTest {

    @isTest
    static void whenNumberofContactIsNagetiveOrLastisEmpty() {
        List<Contact> result = RandomContactFactory.randomContactFactory(-1, '');
        Assert.areEqual(0, result.size(), 'Number of contact is nagetive or last name is null');
    }

    @isTest
    static void whenNumberofContactIsPositiveAndLastisNotEmpty() {
        List<Contact> result = RandomContactFactory.randomContactFactory(2, 'lastName');
        Assert.areEqual(2, result.size(), 'Completed');
    }
}