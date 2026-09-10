import { LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import userId from '@salesforce/user/Id';
import getQueuesWithMembers from '@salesforce/apex/AgentsOnlineController.getQueuesWithMembers';
import getAgentsPresenceStatus from '@salesforce/apex/AgentsOnlineController.getAgentsPresenceStatus';
import getOmnichanelPresenceStatuses from '@salesforce/apex/AgentsOnlineController.getOmnichanelPresenceStatuses';

export default class AgentsOnline extends LightningElement {
    userId = userId;
    
    @track queuesWithMembers = [];
    @track selectedQueueId = null;
    @track agentsInQueue = [];
    
    @track agentsPresence = {};
    @track omnichanelStatuses = {};
    
    @track isLoading = true;
    @track hasError = false;
    @track errorMessage = '';
    @track refreshInterval = null;

    @wire(getRecord, { recordId: userId, fields: ['User.Id', 'User.Name'] })
    wiredUser({ error, data }) {
        if (data) {
            this.loadInitialData();
            this.startAutoRefresh();
        } else if (error) {
            this.handleError('Erreur au chargement de l\'utilisateur');
        }
    }

    async loadInitialData() {
        try {
            this.queuesWithMembers = await getQueuesWithMembers();
            
            if (this.queuesWithMembers.length > 0) {
                this.selectedQueueId = this.queuesWithMembers[0].queueId;
                this.agentsInQueue = this.queuesWithMembers[0].members;
            }
            
            const statusesData = await getOmnichanelPresenceStatuses();
            statusesData.forEach(status => {
                this.omnichanelStatuses[status.Id] = {
                    name: status.Label,
                    color: this.getStatusColor(status.Label)
                };
            });
            
            await this.loadAgentsPresence();
            
            this.isLoading = false;
        } catch (error) {
            this.handleError('Erreur au chargement des données');
            console.error('Error:', error);
        }
    }

    async loadAgentsPresence() {
        try {
            if (this.agentsInQueue.length === 0) return;
            
            const userIds = this.agentsInQueue.map(agent => agent.userId);
            const presenceData = await getAgentsPresenceStatus({ userIds });
            
            this.agentsPresence = {};
            presenceData.forEach(presence => {
                this.agentsPresence[presence.userId] = {
                    statusId: presence.statusId,
                    statusName: presence.statusName || 'Unknown',
                    statusColor: this.getStatusColor(presence.statusName)
                };
            });
            
        } catch (error) {
            console.error('Error loading presence:', error);
        }
    }

    handleQueueChange(event) {
        this.selectedQueueId = event.detail.value;
        
        const queue = this.queuesWithMembers.find(q => q.queueId === this.selectedQueueId);
        if (queue) {
            this.agentsInQueue = queue.members;
            this.loadAgentsPresence();
        }
    }

    startAutoRefresh() {
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
        }
        
        this.refreshInterval = setInterval(() => {
            this.loadAgentsPresence();
        }, 5000);
    }

    handleRefresh() {
        this.loadAgentsPresence();
    }

    disconnectedCallback() {
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
        }
    }

    get hasQueues() {
        return this.queuesWithMembers && this.queuesWithMembers.length > 0;
    }

    get queueOptions() {
        return this.queuesWithMembers.map(queue => ({
            label: `${queue.queueName} (${queue.members.length})`,
            value: queue.queueId
        }));
    }

    getStatusColor(statusName) {
        const colors = {
            'Available': '#04844b',
            'Busy': '#ff9f1c',
            'Break': '#9c89b8',
            'Offline': '#888',
            'In Call': '#0070d2',
            'Away': '#ea001e'
        };
        
        for (const [key, color] of Object.entries(colors)) {
            if (statusName && statusName.includes(key)) {
                return color;
            }
        }
        
        return '#888';
    }

    getStatusIcon(statusName) {
        const icons = {
            'Available': '🟢',
            'Busy': '🟠',
            'Break': '🟣',
            'Offline': '⚫',
            'In Call': '🔵',
            'Away': '🔴'
        };
        
        for (const [key, icon] of Object.entries(icons)) {
            if (statusName && statusName.includes(key)) {
                return icon;
            }
        }
        
        return '⚪';
    }
