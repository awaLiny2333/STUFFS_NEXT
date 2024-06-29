import dataPreferences from '@ohos.data.preferences';

let context = getContext(this);

export class PreferencesTools {

  getPreferencesFromStorage() {
    let preference = dataPreferences.getPreferences(context, "meow");
    return preference;
  }

  async getValueOfKey(keyName: string){
    const pre = await this.getPreferencesFromStorage()
    return await pre.get(keyName,"no")
  }

  putValueOfKey(keyName: string, putContent: string | number){
    this.getPreferencesFromStorage().then((preferencesGot)=>{
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