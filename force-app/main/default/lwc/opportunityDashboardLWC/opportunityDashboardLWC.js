import { LightningElement, wire } from "lwc";
import { gql, graphql } from "lightning/uiGraphQLApi";
import { deleteRecord, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ID_FIELD from "@salesforce/schema/Opportunity.Id";
import { RefreshEvent } from "lightning/refresh";

const actions = [
  { label: "Show details", name: "show_details" },
  { label: "Delete", name: "delete" }
];

const columns = [
  { label: "Id", fieldName: "Id" },
  { label: "Name", fieldName: "Name", editable: true },
  { label: "Amount", fieldName: "Amount", type: "currency", editable: true },
  { label: "CloseDate", fieldName: "CloseDate", type:'date', editable: true },
  { label: "Owner", fieldName: "Owner" },
  {
    type: "action",
    typeAttributes: { rowActions: actions }
  }
];

const pageSize = 10;

export default class OpportunityDashboardLWC extends LightningElement {
  records = [];
  columns = columns;
  data;
  graphqlData;
  after;
  pageNumber = 1;
  _searchInputValue;
  rowOffset = 0;
  showLoading = false

  get searchText() {
    return this._searchInputValue || "";
  }
  set searchText(value) {
    this._searchInputValue = value;
  }
  get showSpinner() {
    return this.showLoading
  }
  set showSpinner(value) {
    this.showLoading = value
  }
  // Handle input change event
  handleInputChange(event) {
    // Set the property value when input changes
    console.log("inputChange: ", event.target.value);
    this.searchText = event.target.value;
  }

  @wire(graphql, {
    query: gql`
      query getAccounts($after: String, $pageSize: Int!, $searchText: String) {
        uiapi {
          query {
            Opportunity(
              first: $pageSize
              after: $after
              orderBy: { Name: { order: ASC } }
              where: { Name: { like: $searchText } }
            ) {
              edges {
                node {
                  Id
                  Name {
                    value
                  }
                  CloseDate {
                    value
                  }
                  Amount {
                    value
                  }
                  Owner {
                    Id
                    Name {
                      value
                    }
                  }
                }
              }
              totalCount
              pageInfo {
                hasNextPage
                hasPreviousPage
                startCursor
                endCursor
              }
            }
          }
        }
      }
    `,
    variables: "$variables"
  })
  graphqlQueryResult({ data, errors }) {
    this.showLoading = false
    if (data) {
      this.graphqlData = data;
      const opportunityEdges = data.uiapi.query.Opportunity.edges;

      // Extracting record data from each edge
      this.records = opportunityEdges.map((edge) => {
        const node = edge.node;
        return {
          Id: node.Id,
          Name: node.Name.value,
          CloseDate: node.CloseDate.value,
          Amount: node.Amount.value,
          Owner: node.Owner.Name.value
        };
      });
      console.log("records: ", this.records);
    } else {
      this.errors = errors;
      console.log("errors: ", this.errors);
    }
  }

  get variables() {
    return {
      after: this.after || null,
      searchText: "%" + this.searchText + "%",
      pageSize
    };
  }

  connectedCallback() {
    this.showLoading = true
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case "delete":
        console.log("action delete");
        this.deleteRow(row);
        break;
      case "show_details":
        console.log("action show_details");
        // this.showRowDetails(row);
        break;
      default:
    }
  }

  deleteRow(row) {
    const { Id } = row;
    console.log("Id: ", Id);
    try {
      deleteRecord(Id);
    } catch (error) {
      console.log('delete error: ',error);
    }
  }

  get currentPageNumber() {
    return this.totalCount === 0 ? 0 : this.pageNumber;
  }

  get isFirstPage() {
    return !this.graphqlData?.uiapi.query.Opportunity.pageInfo.hasPreviousPage;
  }

  get isLastPage() {
    return !this.graphqlData?.uiapi.query.Opportunity.pageInfo.hasNextPage;
  }

  get totalCount() {
    return this.graphqlData?.uiapi.query.Opportunity.totalCount || 0;
  }

  get totalPages() {
    return Math.ceil(this.totalCount / pageSize);
  }

  handleNext() {
    if (this.pageNumber < this.totalPages) {
      this.showSpinner = true
      this.after = this.graphqlData?.uiapi.query.Opportunity.pageInfo.endCursor;
      this.rowOffset = this.pageNumber * 10;
      this.pageNumber++;
    }
  }

  handlePrevious() {
    this.after = null;
    this.pageNumber = 1;
    this.rowOffset = (this.pageNumber - 1) * 10;
  }

  async handleCellChange(event) {
    const draftValues = event.detail.draftValues;
    var recordId = this.getRecordId(draftValues);
    const filteredFieldName = Object.keys(draftValues[0]).filter(
      (fieldName) => fieldName !== "id"
    )[0];
    console.log("keys: ", filteredFieldName);
    // Get the value corresponding to filteredFieldName
    const filteredFieldValue = draftValues[0][filteredFieldName];
    console.log("Value of filteredFieldName:", filteredFieldValue);
    const fields = {};
    fields[ID_FIELD.fieldApiName] = recordId;
    fields[filteredFieldName] = filteredFieldValue;
    const recordInput = { fields };

    try {
      await updateRecord(recordInput);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "Contact updated",
          variant: "success"
        })
      );
      // Dispatch the refresh event
      this.dispatchEvent(new RefreshEvent());
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error updating record, try again...",
          message: error.body.message,
          variant: "error"
        })
      );
    }
  }
  getRecordId(draftValues) {
    console.log("draft values:", draftValues);
    const rowId = Number(draftValues[0].id.split("-")[1]);
    // console.log("changed record rowId: ", rowId;
    console.log("changed record: ", JSON.stringify(this.records[0]));
    // console.log("changed record: ", this.records[rowId].Id);
    return this.records[rowId].Id;
  }

  showErrorToast(title, message) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: "error"
      })
    );
  }
}
