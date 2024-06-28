import dataPreferences from '@ohos.data.preferences';

let context = getContext(this);

export class PreferencesTools {

  getPreferencesFromStorage(dbName: string) {
    let preference = dataPreferences.getPreferences(context, dbName);
    return preference;
  }

  async getValueOfKey(dbName: string,keyName: string){
    const pre = await this.getPreferencesFromStorage(dbName)
    return await pre.get(keyName,"no")
  }

  putValueOfKey(dbName:string, keyName: string, putContent: string | number){
    this.getPreferencesFromStorage(dbName).then((preferencesGot)=>{
      try {
        preferencesGot.put(keyName,putContent)
      }
      catch (result){
        console.log(result + "qwq")
      }

      preferencesGot.flush();
      console.log(putContent.toString() + " PUT qwq")
    });
  }

}

export default new PreferencesTools()