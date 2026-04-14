import { determineStyleFromVariant, fetchNotifyConfig, NOTIFY_CONFIG } from "./config.js";

const { useQuasar } = Quasar;
const { onMounted, onUnmounted } = Vue;

const fetchNui = async (evName, data) => {
    const resourceName = window.GetParentResourceName();

    const rawResp = await fetch(`https://${resourceName}/${evName}`, {
        body: JSON.stringify(data),
        headers: {
            "Content-Type": "application/json; charset=UTF8",
        },
        method: "POST",
    });

    return await rawResp.json();
};

window.fetchNui = fetchNui;

const app = Vue.createApp({
    setup() {
        const $q = useQuasar();

        const showNotif = async ({ data }) => {
            if (data?.action !== "notify") return;

            const { text, length, type, caption, icon: dataIcon } = data;
            if (!NOTIFY_CONFIG || !NOTIFY_CONFIG.VariantDefinitions) {
                await fetchNotifyConfig();
            }

            let { classes, icon } = determineStyleFromVariant(type);

            if (dataIcon) {
                icon = dataIcon;
            }

            $q.notify({
                message: text,
                multiLine: text.length > 100,
                group: NOTIFY_CONFIG.NotificationStyling.group ?? false,
                progress: NOTIFY_CONFIG.NotificationStyling.progress ?? true,
                position: NOTIFY_CONFIG.NotificationStyling.position ?? "right",
                timeout: length,
                caption,
                classes,
                icon,
            });
        };
        onMounted(() => {
            window.addEventListener("message", showNotif);
        });
        onUnmounted(() => {
            window.removeEventListener("message", showNotif);
        });
        return {};
    },
});

app.use(Quasar, { config: {} });
app.mount("#q-app");
