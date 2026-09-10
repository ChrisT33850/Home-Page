
import { LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import userId from '@salesforce/user/Id';
import getUserQueues from '@salesforce/apex/HelpdeskKanbanController.getUserQueues';
import getQueuesWithCaseCount from '@salesforce/apex/HelpdeskKanbanController.getQueuesWithCaseCount';
import getCasesForKanban from '@salesforce/apex/HelpdeskKanbanController.getCasesForKanban';
import getKanbanStatuses from '@salesforce/apex/HelpdeskKanbanController.getKanbanStatuses';
import updateCaseKanbanStatus from '@salesforce/apex/HelpdeskKanbanController.updateCaseKanbanStatus';

export default class HelpdeskKanban extends LightningElement {
    userId = userId;
    
    // Queues
    @track queuesWithCount = [];
    selectedQueueId = null;
    
    // Kanban
    @track kanbanStatuses = [];
    @track allCases = [];
    @track casesByStatus = {};
    
    // État
    @track isLoading = true;
    @track hasError = false;
    @track errorMessage = '';
    
    // Drag & Drop
    @track draggedCase = null;
    @track draggedFromStatus = null;

    @wire(getRecord, { recordId: userId, fields: ['User.Id', 'User.Name'] })
    wiredUser({ error, data }) {
        if (data) {
            this.loadInitialData();
        } else if (error) {
            this.handleError('Erreur au chargement de l\'utilisateur');
        }
    }

    async loadInitialData() {
