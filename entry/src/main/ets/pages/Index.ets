import preferences from '@ohos.data.preferences';

@Entry
@ComponentV2
struct Index {
  @Local message: string = "Hello World"
    async storeName() {
    let context = getContext(this);
    let pref = await preferences.getPreferences(context, 'my_prefs');
    await pref.put('name', '刘洺旭');
    await pref.flush();
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .width('100%')
        .height('50%')
        .align(Alignment.Top)
      Button('存储姓名')
        .onClick(() => {
          this.storeName();
        })
        .width('100%')
        .height('50%')
        .align(Alignment.Bottom)
    }
    .height('100%')
    .width('100%')
  }
}