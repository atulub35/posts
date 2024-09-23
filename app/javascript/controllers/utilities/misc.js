import { debounce } from 'lodash';
export const delayedAction = debounce(
    (callback) => {
        callback()
    },
    500,
    {
        leading: false,
        trailing: true,
    }
)