import { distributedKVStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

let kvManager: distributedKVStore.KVManager | undefined = undefined;

let kvStore: distributedKVStore.SingleKVStore | undefined = undefined;

let context = getContext(this);

const kvManagerConfig: distributedKVStore.KVManagerConfig = {
  context: context,
  bundleName: 'com.next.liny.linys1stnext'
};
try {
  kvManager = distributedKVStore.createKVManager(kvManagerConfig);
  console.info('Succeeded in creating KVManager.');
  // 继续创建获取数据库
} catch (e) {
  let error = e as BusinessError;
  console.error(`Failed to create KVManager. Code:${error.code},message:${error.message}`);
}

if (kvManager !== undefined) {
  kvManager = kvManager as distributedKVStore.KVManager;
  //进行后续操作
  //...
  try {
    const options: distributedKVStore.Options = {
      createIfMissing: true,
      encrypt: false,
      backup: false,
      autoSync: false,
      // kvStoreType不填时，默认创建多设备协同数据库
      kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
      // 多设备协同数据库：kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
      securityLevel: distributedKVStore.SecurityLevel.S1
    };
    kvManager.getKVStore<distributedKVStore.SingleKVStore>('linys_Store', options, (err, store: distributedKVStore.SingleKVStore) => {
      if (err) {
        console.error(`Failed to get KVStore: Code:${err.code},message:${err.message}`);
        return;
      }
      console.info('Succeeded in getting KVStore.');
      kvStore = store;
      // 请确保获取到键值数据库实例后，再进行相关数据操作
    });

  } catch (e) {
    let error = e as BusinessError;
    console.error(`An unexpected error occurred. Code:${error.code},message:${error.message}`);
  }

  if (kvStore !== undefined) {
    kvStore = kvStore as distributedKVStore.SingleKVStore;
    //进行后续操作
    //...

  }
}

export class KVManagerTools {

  async getValueOfKey(keyName: string) {
    if (kvStore !== undefined) {
      return await kvStore.get(keyName)
    } else {
      console.log("Cannot get because of a null kvstore " + keyName)
      return "no";
    }
  }

  putValueOfKey(keyName: string, putContent: string) {
    if (kvStore !== undefined) {
      kvStore.put(keyName, putContent, (err) => {
        if (err !== undefined) {
          console.error(`Failed to put data. Code: ${err.code},message:${err.message}`);
          return;
        } else {
          console.info('Succeeded in putting data. Data: ' + putContent + " qwq");
        }
      });
    } else {
      console.log("Cannot put because of a null kvstore " + putContent)
    }
  }

  delValurOfKey(keyName: string) {
    if (kvStore !== undefined) {
      kvStore.delete(keyName, (err) => {
        if (err !== undefined) {
          console.error(`Failed to delete data. Code:${err.code},message:${err.message}`);
          return;
        }
        console.info('Succeeded in deleting data.');
      });
    }
  }
}

export default new KVManagerTools()