@isTest
public class contactProductDetailsControllerTest {
    @testSetup static void setup() {
        //Product with PriceBookEntry
        Product2 product = new Product2();
        product.Name='Standard';
        product.ProductCode='Standard';
        product.CurrencyIsoCode='EUR';
        product.IsActive=true;
        insert product;
        
        //Product without PriceBookEntry
        Product2 secondproduct = new Product2();
        secondproduct.Name='Metal';
        secondproduct.ProductCode='Metal';
        secondproduct.CurrencyIsoCode='EUR';
        secondproduct.IsActive=true;
        insert secondproduct;
        
        //Creating Pricebooks for all types of Charges
        PriceBook2 pricebook = new PriceBook2();
        pricebook.Name ='DE ATM Fee';
        pricebook.Description='ATM Fee';
        pricebook.Country__c='DE';
        pricebook.IsActive=true;
        insert pricebook;
        PriceBook2 secondpricebook = new PriceBook2();
        secondpricebook.Name ='DE Card Replacement Cost';
        secondpricebook.Description='Card Replacement Cost';
        secondpricebook.Country__c='DE';
        secondpricebook.IsActive=true;
        insert secondpricebook;
        PriceBook2 thirdpricebook = new PriceBook2();
        thirdpricebook.Name ='DE Cost per Month';
        thirdpricebook.Description='Cost per Calendar Month';
        thirdpricebook.Country__c='DE';
        thirdpricebook.IsActive=true;
        insert thirdpricebook;
        
        //Mandatory Price Book Entry with standard pricebook
        PriceBookEntry priceEntry = new PriceBookEntry();
        priceEntry.Pricebook2Id=Test.getStandardPricebookId();
        priceEntry.Product2Id=product.Id;
        priceEntry.IsActive=false;
        priceEntry.CurrencyIsoCode='EUR';
        priceEntry.UnitPrice=9.90;
        insert priceEntry;
        
        //Price Book Entry without currency value
        PriceBookEntry secondpriceEntry = new PriceBookEntry();
        secondpriceEntry.Pricebook2Id=pricebook.Id;
        secondpriceEntry.Product2Id=product.Id;
        secondpriceEntry.IsActive=false;
        secondpriceEntry.CurrencyIsoCode='EUR';
        secondpriceEntry.UnitPrice=0.00;
        secondpriceEntry.Category_Value__c='1.7%';
        insert secondpriceEntry;
        
        //Price Book Entry with currency value
        PriceBookEntry thirdpriceEntry = new PriceBookEntry();
        thirdpriceEntry.Pricebook2Id=secondpricebook.Id;
        thirdpriceEntry.Product2Id=product.Id;
        thirdpriceEntry.IsActive=false;
        thirdpriceEntry.CurrencyIsoCode='EUR';
        thirdpriceEntry.UnitPrice=6;
        insert thirdpriceEntry;
        PriceBookEntry fourthpriceEntry = new PriceBookEntry();
        fourthpriceEntry.Pricebook2Id=thirdpricebook.Id;
        fourthpriceEntry.Product2Id=product.Id;
        fourthpriceEntry.IsActive=false;
        fourthpriceEntry.CurrencyIsoCode='EUR';
        fourthpriceEntry.UnitPrice=0.00;
        insert fourthpriceEntry;
        
        //Contact record with Product and Country and 1st product
        Contact contactRecord= new Contact();
        contactRecord.LastName='Test Ankit';
        contactRecord.Product__c=product.Id;
        contactRecord.Home_Country__c='DE';
        contactRecord.UUID__c='1234';
        insert contactRecord;
        
        //Contact record without Product and Country 
        Contact secondcontactRecord= new Contact();
        secondcontactRecord.LastName='Test NoProductCountry';
        secondcontactRecord.UUID__c='12345';
        insert secondcontactRecord;
        
        //Contact record with Product and Country and second product with no pricebook entry
        Contact thirdcontactRecord= new Contact();
        thirdcontactRecord.LastName='Test Ankit2';
        thirdcontactRecord.Product__c=secondproduct.Id;
        thirdcontactRecord.Home_Country__c='DE';
        thirdcontactRecord.UUID__c='123456';
        insert thirdcontactRecord;
        
        Case caseRecord= new Case();
        caseRecord.Subject='Test Case with Contact';
        caseRecord.Status='New';
        caseRecord.Origin='Phone';
        caseRecord.CurrencyIsoCode='EUR';
        caseRecord.ContactId=contactRecord.Id;
        insert caseRecord;
        Case secondcaseRecord= new Case();
        secondcaseRecord.Subject='Test Case without Contact';
        secondcaseRecord.Status='New';
        secondcaseRecord.Origin='Phone';
        secondcaseRecord.CurrencyIsoCode='EUR';
        insert secondcaseRecord;
        Case thirdcaseRecord= new Case();
        thirdcaseRecord.Subject='Test Case with Contact no Product or Country';
        thirdcaseRecord.Status='New';
        thirdcaseRecord.Origin='Phone';
        thirdcaseRecord.CurrencyIsoCode='EUR';
        thirdcaseRecord.ContactId=secondcontactRecord.Id;
        insert thirdcaseRecord;
        Case fourthcaseRecord= new Case();
        fourthcaseRecord.Subject='Test Case with Contact no PriceBook Entry';
        fourthcaseRecord.Status='New';
        fourthcaseRecord.Origin='Phone';
        fourthcaseRecord.CurrencyIsoCode='EUR';
        fourthcaseRecord.ContactId=thirdcontactRecord.Id;
        insert fourthcaseRecord;
    }
    
    //Test Case 1: Fetching Product Details Successfully
    static testMethod void  testFetchProductDetails_Success() {
        // Mocking a Case record with an associated Contact record
        Case caseRecord = [select id from Case where Subject='Test Case with Contact' limit 1];
        Test.startTest();
        contactProductDetailsController.productDetailsWrapper result = contactProductDetailsController.fetchProductdetails(caseRecord.Id);
        Test.stopTest();
        // Asserting that the result contains the expected product details
        System.assert(result.productName != null && result.country != null && result.priceBookList != null);
    }
	
    //Test Case 2: No Contact Available
    static testMethod void  testFetchProductDetails_NoContact() {
        // Mocking a Case record without an associated Contact record
        Case caseRecord = [select id from Case where Subject='Test Case without Contact' limit 1];
        Test.startTest();
        contactProductDetailsController.productDetailsWrapper result = contactProductDetailsController.fetchProductdetails(caseRecord.Id);
        Test.stopTest();
        // Asserting that the result contains the appropriate error message
        System.assert(result.message.contains('No contact available.'));
    }
    
	//Test Case 3: Product and Country Not Associated with Contact
    static testMethod void testFetchProductDetails_NoProductOrCountry() {
        // Mocking a Contact record without associated Product and Country
        Case caseRecord = [select id from Case where Subject='Test Case with Contact no Product or Country' limit 1];
        Test.startTest();
        contactProductDetailsController.productDetailsWrapper result = contactProductDetailsController.fetchProductdetails(caseRecord.Id);
        Test.stopTest();
        // Asserting that the result contains the appropriate error message
        System.assert(result.message.contains('Product and Country needs to be associated with the contact to get product details.'));
    }

    // Test Case 4: Product and Country Associated with Contact with pricebook entry
    static testMethod void testFetchProductDetails_ProductAndCountryAssociated() {
        // Mocking a Case record with an associated Contact record
        Case caseRecord = [select id from Case where Subject='Test Case with Contact' limit 1];
        Test.startTest();
        contactProductDetailsController.productDetailsWrapper result = contactProductDetailsController.fetchProductdetails(caseRecord.Id);
        Test.stopTest();

        // Assert that the result contains the expected product details
        System.assertEquals('Standard', result.productName);
        System.assertEquals('Germany', result.country); // Assuming label is retrieved correctly
        System.assertEquals(3, result.priceBookList.size()); // Assuming one pricebook entry is returned
    }
    // Test Case 5: No Pricebook Entry Available
    static testMethod void testFetchProductDetails_NoPricebookEntry() {
        // Mocking a Contact record with associated Product and Country
        Case caseRecord = [select id from Case where Subject='Test Case with Contact no PriceBook Entry' limit 1];
        Test.startTest();
        contactProductDetailsController.productDetailsWrapper result = contactProductDetailsController.fetchProductdetails(caseRecord.Id);
        Test.stopTest();
			
        // Assert that the result contains the appropriate error message
        System.assert(result.message.contains('No pricebook entry available.'));
    }
    // Test Case 8: Error Handling
	static testMethod void testErrorHandling() {
        // Mock an exception scenario
        // For example, pass an invalid recordId to force an exception
        Test.startTest();
        try {
            contactProductDetailsController.fetchProductdetails('5006F00001L2EAqQAN');
        } catch (AuraHandledException e) {
            // Assert that the correct error message is thrown
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        Test.stopTest();
    }
    // Test Case 9: Error Handling for Webservice class
	static testMethod void testGetContactsByUUID_NoUUID() {
        // Mock a RestRequest without a UUID
        RestRequest request = new RestRequest();
        request.requestURI = '/contactUUID/';
        RestContext.request = request;

        // Mock no UUID available in the request
        Test.startTest();
        contactProductDetailsController.productDetailsWrapper result = contactProductDetailsWebservice.getContactsByUUID();
        Test.stopTest();

        // Assert that the result contains the appropriate error message
        System.assert(result.message.contains('UUID not available.'));
    }
    // Test Case 10: Error Handling for Webservice class with wrong UUID
	static testMethod void testGetContactsByUUID_Invalid_UUID() {
        // Mock a RestRequest without a UUID
        RestRequest request = new RestRequest();
        request.requestURI = '/contactUUID/invalid';
        RestContext.request = request;

        // Mock no UUID available in the request
        Test.startTest();
        contactProductDetailsController.productDetailsWrapper result = contactProductDetailsWebservice.getContactsByUUID();
        Test.stopTest();

        // Assert that the result contains the appropriate error message
        System.assert(result.message.contains('invalid contact not available.'));
    }
    // Test Case 11: Success product fetched with correct UUID
	static testMethod void testGetContactsByUUID_Valid_UUID() {
        // Mock a RestRequest without a UUID
        RestRequest request = new RestRequest();
        request.requestURI = '/contactUUID/1234';
        RestContext.request = request;

        // Mock no UUID available in the request
        Test.startTest();
        contactProductDetailsController.productDetailsWrapper result = contactProductDetailsWebservice.getContactsByUUID();
        Test.stopTest();

        // Assert that the result contains the appropriate error message
        System.assert(result.message.contains('3 pricebook entry available.'));
    }
}