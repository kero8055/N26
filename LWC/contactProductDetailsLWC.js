import { LightningElement, api, wire, track } from 'lwc';
import fetchProductDetails from '@salesforce/apex/contactProductDetailsController.fetchProductdetails';

export default class ContactProductDetails extends LightningElement {
    @api recordId; // The record ID from the record page
    @track productDetails;
    noPriceBookEntries=false; 
    productName;
    countryName;
    message;
    showProductCountry=false;
    //this wire method is used to retreive product data based on case recordId.
    @wire(fetchProductDetails, { recordId: '$recordId' })
    wiredProductDetails({ error, data }) {
        if (data) {
            this.productName = data.productName;
            this.countryName=  data.country;
            if(data.productName || data.country){
                this.showProductCountry=true;
            }
            this.message=data.message;
            if(data.priceBookList){
                if(data.priceBookList.length==0){
                    this.noPriceBookEntries=true;
                 }
                 else{
                     this.productDetails=data.priceBookList;
                     this.noPriceBookEntries=false;
                 }
            }
            else{
                this.noPriceBookEntries=true;
            }
        } else if (error) {
            this.noPriceBookEntries=true;
            this.productDetails = undefined;
            
        }
    }
}