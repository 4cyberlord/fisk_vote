<div x-data="{
    messages: [],
    remove(mid) {
        $dispatch('close-me', { id: mid })
        let m = this.messages.filter((m) => { return m.id == mid })
        if (m.length) {
            setTimeout(() => {
                this.messages.splice(this.messages.indexOf(m[0]), 1)
            }, 200)
        }
    },
}"
    @notify.window="
        let mid = Date.now();
        let notificationData = $event.detail;
        // Handle both Livewire 3 format (object with message/type properties) and direct values
        let message = typeof notificationData === 'string'
            ? notificationData
            : (notificationData.message || notificationData.msg || notificationData);
        let type = notificationData.type || 'info';
        messages.push({id: mid, msg: message, type: type});
        setTimeout(() => { remove(mid) }, 5000)
    "
    x-init="// Listen for browser events (CustomEvent)
    window.addEventListener('notify', function(event) {
        let mid = Date.now();
        let notificationData = event.detail || {};
        let message = typeof notificationData === 'string' ?
            notificationData :
            (notificationData.message || notificationData.msg || notificationData);
        let type = notificationData.type || 'info';
        messages.push({ id: mid, msg: message, type: type });
        setTimeout(() => { remove(mid) }, 5000);
    });
    
    // Also listen for Livewire 3 events
    if (typeof Livewire !== 'undefined') {
        Livewire.on('notify', (data) => {
            let mid = Date.now();
            let message = data.message || data.msg || data;
            let type = data.type || 'info';
            messages.push({ id: mid, msg: message, type: type });
            setTimeout(() => { remove(mid) }, 5000);
        });
    }"
    class="z-50 fixed inset-0 flex items-end justify-center px-4 py-6 pointer-events-none sm:p-6 sm:items-start sm:justify-end">
    <template x-for="(message, messageIndex) in messages" :key="messageIndex" hidden>
        <div x-data="{ id: message.id, show: false }" x-init="$nextTick(() => { show = true })" x-show="show"
            @close-me.window="if ($event.detail.id == id) {show=false}"
            x-transition:enter="transform ease-out duration-300 transition"
            x-transition:enter-start="translate-y-2 opacity-0 sm:translate-y-0 sm:translate-x-2"
            x-transition:enter-end="translate-y-0 opacity-100 sm:translate-x-0"
            x-transition:leave="transition ease-in duration-200" x-transition:leave-start="opacity-100"
            x-transition:leave-end="opacity-0"
            class="max-w-sm w-full bg-white dark:bg-gray-800 shadow-lg rounded-lg pointer-events-auto ring-1 ring-black ring-opacity-5 overflow-hidden">
            <div class="p-4">
                <div class="flex items-start">
                    <div class="flex-shrink-0">
                        <!-- Success Icon -->
                        <template x-if="message.type === 'success'">
                            <svg class="h-6 w-6 text-green-400" xmlns="http://www.w3.org/2000/svg" fill="none"
                                viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </template>
                        <!-- Error/Danger Icon -->
                        <template x-if="message.type === 'danger' || message.type === 'error'">
                            <svg class="h-6 w-6 text-red-400" xmlns="http://www.w3.org/2000/svg" fill="none"
                                viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </template>
                        <!-- Warning Icon -->
                        <template x-if="message.type === 'warning'">
                            <svg class="h-6 w-6 text-yellow-400" xmlns="http://www.w3.org/2000/svg" fill="none"
                                viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                            </svg>
                        </template>
                        <!-- Info Icon (default) -->
                        <template x-if="!message.type || message.type === 'info'">
                            <svg class="h-6 w-6 text-blue-400" xmlns="http://www.w3.org/2000/svg" fill="none"
                                viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </template>
                    </div>
                    <div class="ml-3 w-0 flex-1 pt-0.5">
                        <p x-html="message.msg" class="text-sm font-medium text-gray-900 dark:text-gray-100"></p>
                    </div>
                    <div class="ml-4 flex-shrink-0 flex">
                        <button @click="remove(message.id)"
                            class="bg-white dark:bg-gray-800 rounded-md inline-flex text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                            <span class="sr-only">Close</span>
                            <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"
                                fill="currentColor">
                                <path fill-rule="evenodd"
                                    d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                                    clip-rule="evenodd" />
                            </svg>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </template>
</div>
