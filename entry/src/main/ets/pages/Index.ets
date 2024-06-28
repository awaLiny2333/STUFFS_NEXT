import display from '@ohos.display';
import PreferencesTools from '../blocks/PreferencesTools';
import { SegmentButton, SegmentButtonOptions } from '@ohos.arkui.advanced.SegmentButton';
import { ConfigurationConstant } from '@kit.AbilityKit';
import KVManagerTools from '../blocks/KVManagerTools';
import { systemDateTime } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State bottomRectHeight: string = AppStorage.get<number>('bottomRectHeight') + 'px';
  @State use_backdrop: boolean = false;
  @State settings_db_name: string = "settings"
  @State showBorder: boolean = false
  @State Screen_width: number = display.getDefaultDisplaySync().width
  @State Screen_height: number = display.getDefaultDisplaySync().height
  @State APP_open_time: number = 0
  @State waterFlow_Layout: string = ""
  @State waterFlow_Columns: number = 0
  @State waterFlow_firstScroll: boolean = true
  @State Title_y_offset: number = 50
  @State Title_opacity: number = 0
  @State Title_top_margin: number = 90
  @State Title_font_zoom: number = 1.00
  @State subTitle_y_offset: number = 50
  @State subTitle_opacity: number = 0
  @State block_y_offset: number = 50
  @State block_opacity: number = 0
  @State block_settings_height: number = 170
  @State block_settings_height_content: number = 1030
  @State block_settings_offset_content: number = 50
  @State block_settings_is_open: boolean = false
  @State block_add_is_open: boolean = false
  @State current_time_period: string = "Morning"
  @State Greetings_address: string = "app.string.Greetings_Morning"
  @State Color_scheme_light_default: string = "#5D1E3928,#FFC1CFC6,#FFFFFFFF,#FF334C42,#B0263F0F,#FFE3ECE7"
  @State Color_scheme_dark_default: string = "#B3243930,#FF1F2B26,#FFC1CFC6,#FFC1CFC6,#80090E0B,#FF3F5A4E"
  @State Color_scheme_light: string[] = this.Color_scheme_light_default.split(",")
  @State Color_scheme_dark: string[] = this.Color_scheme_dark_default.split(",")
  @State Color_scheme: string[] = []
  @State Blur_radius: number = 25
  @State Min_block_size: number = 450
  @State Color_scheme_edit_light: string = this.Color_scheme_light.toString()
  @State Color_scheme_edit_dark: string = this.Color_scheme_dark.toString()
  @State Color_scheme_edit_confirm: number = 0
  @State Add_name_edit: string = ""
  @State Add_description_edit: string = ""
  @State Add_Length: number = 200
  @State Add_Length_Description: string = "app.string.Add_Length_Notice_Short"
  @State Add_Time_Limit: number = 31
  @State Add_Time_Limit_Description: string = "app.string.Add_Day"
  @State Add_Value_Target: number = 233
  @State Add_Value_Target_Description: string = "app.string.Add_Value_Unit_Hour"
  @State font_color: string = this.Color_scheme[2]
  @State block_background: string = this.Color_scheme[4]
  @State ani_param: AnimateParam = { duration: 300, curve: Curve.ExtremeDeceleration }
  @State @Watch('onChangeBackground') backdrop_tab_choose: number[] = [0]
  @State backdrop_tab_Options: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [
      { text: $r("app.string.Settings_Content_Background_Color") },
      { text: $r("app.string.Settings_Content_Background_Image") }],
    fontColor: this.font_color,
    selectedFontColor: this.block_background,
    fontWeight: FontWeight.Medium,
    // backgroundColor: this.Color_scheme[0],
    selectedFontWeight: FontWeight.Bolder,
    selectedBackgroundColor: this.font_color
  })
  @StorageProp('currentColorMode') @Watch('onColorModeChange') currentColorMode: number = 0
  @StorageProp('currentDirection') @Watch('onDirectionChange') currentDirection: number = 1
  @State is_first_open: boolean = true
  @State cards_name: string[] = []
  @State cards_desc: string[] = []
  @State cards_length: number[] = []
  @State cards_time_limit: number[] = []
  @State cards_target: number[] = []
  @State cards_done: number[] = []
  @State cards_start: number[] = []
  @State cards_end: number[] = []
  @State cards_lengths_each_column: number[] = [130]
  @State @Watch('onCardExpand') card_expanding: number = -1
  @State last_expanded: number = -1
  @State card_scroll_up: number = 0
  @State card_remaining_days: number = 0
  @State card_slogan: string = "Card_Progress_Desc_Time_"
  @State cover_continue_opacity: number = 1
  scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    this.APP_open_time += 1
    PreferencesTools.getValueOfKey(this.settings_db_name, "use_backdrop").then((result) => {
      if (result == "no") {
        // First open app then put
        PreferencesTools.putValueOfKey(this.settings_db_name, "use_backdrop", "false")
        PreferencesTools.putValueOfKey(this.settings_db_name, "color_scheme_light",
          this.Color_scheme_light_default)
        PreferencesTools.putValueOfKey(this.settings_db_name, "color_scheme_dark",
          this.Color_scheme_dark_default)
        PreferencesTools.putValueOfKey(this.settings_db_name, "blur_radius", 25)
        PreferencesTools.putValueOfKey(this.settings_db_name, "Min_block_size", this.Min_block_size)
        PreferencesTools.putValueOfKey(this.settings_db_name, "APP_open_time", this.APP_open_time)

        this.storeCards()

      } else {
        let temp: string[] = []
        this.is_first_open = false // Used before then directly load
        KVManagerTools.getValueOfKey("cards_name").then((result) => {
          this.cards_name = (result as string).split(",")
          // console.log(this.cards_name.length.toString() + " qwqwqwq")
          // console.log(this.cards_name.toString() + " qwqwqwq")
          if (this.cards_name[0] == "") {
            this.cards_name = []
          }
        })
        KVManagerTools.getValueOfKey("cards_desc").then((result) => {
          this.cards_desc = (result as string).split(",")
          // console.log(this.cards_desc.toString() + " qwqwqwq")
          if (this.cards_desc[0] == "") {
            this.cards_desc = []
          }
        })
        KVManagerTools.getValueOfKey("cards_length").then((result) => {
          temp = (result as string).split(",")
          for (let index = 0; index < temp.length; index++) {
            this.cards_length.push(Number(temp[index]))
          }
          if (temp[0] == "") {
            this.cards_length = []
          }

          console.log(this.cards_length.toString() + " qwqwqwq")
        })
        KVManagerTools.getValueOfKey("cards_time_limit").then((result) => {
          temp = (result as string).split(",")
          for (let index = 0; index < temp.length; index++) {
            this.cards_time_limit.push(Number(temp[index]))
          }
          // console.log(this.Add_Time_Limit.toString() + "  qwqwqwq")
          if (temp[0] == "") {
            this.cards_time_limit = []
          }
        })
        KVManagerTools.getValueOfKey("cards_target").then((result) => {
          temp = (result as string).split(",")
          for (let index = 0; index < temp.length; index++) {
            this.cards_target.push(Number(temp[index]))
          }
          // console.log(this.cards_target.toString() + "  qwqwqwq")
          if (temp[0] == "") {
            this.cards_target = []
          }
        })
        KVManagerTools.getValueOfKey("cards_done").then((result) => {
          temp = (result as string).split(",")
          for (let index = 0; index < temp.length; index++) {
            this.cards_done.push(Number(temp[index]))
          }
          // console.log(this.cards_done.toString() + "  qwqwqwq")
          if (temp[0] == "") {
            this.cards_done = []
          }
        })
        KVManagerTools.getValueOfKey("cards_start").then((result) => {
          temp = (result as string).split(",")
          for (let index = 0; index < temp.length; index++) {
            this.cards_start.push(Number(temp[index]))
          }
          // console.log(this.cards_done.toString() + "  qwqwqwq")
          if (temp[0] == "") {
            this.cards_start = []
          }
        })
        KVManagerTools.getValueOfKey("cards_end").then((result) => {
          temp = (result as string).split(",")
          for (let index = 0; index < temp.length; index++) {
            this.cards_end.push(Number(temp[index]))
          }
          // console.log(this.cards_done.toString() + "  qwqwqwq")
          if (temp[0] == "") {
            this.cards_end = []
          }
        })
      }
      this.readDesign()
    })
  }

  onBackPress(): boolean | void {
    if (this.card_expanding != -1) {
      this.card_expanding = -1
      return true
    }
  }

  build() {
    RelativeContainer() {
      Image($r("app.media.bg1"))// .width(this.card_expanding == -1? "100%": this.Screen_width * 1.2)
        // .height(this.card_expanding == -1? "100%": this.Screen_height * 1.2)
        .width("100%")
        .height("100%")
        .animation({ duration: 800, curve: Curve.ExtremeDeceleration })
        .alignRules({
          center: { anchor: "__container__", align: VerticalAlign.Center },
          middle: { anchor: "__container__", align: HorizontalAlign.Center }
        })
      // Backdrop

      Row() {}
      .height("100%")
      .width("100%")
      .backgroundColor(this.cover_continue_opacity == 0?
        (this.use_backdrop ? this.Color_scheme[0] : this.Color_scheme[1])
        : $r('app.color.start_window_background')
      )
      .animation({ duration: 300, curve: Curve.ExtremeDeceleration })

      // Backdrop Cover

      RelativeContainer() {

        Row() {
          Text($r("app.string.Entry_Title"))
            .border({ color: "#FFFFFF", width: this.showBorder ? 2 : 0 })
            .fontSize(45 * this.Title_font_zoom)
            .fontWeight(FontWeight.Bolder)
            .position({ y: this.Title_y_offset })
            .opacity(this.Title_opacity)
            .animation(this.animateParam(200))
            .onAreaChange(() => {
              this.Title_opacity = 100
              this.Title_y_offset = 0
            })
            .fontColor(this.font_color)
            .animation(this.animateParam(0))

          Text($r("app.string.Entry_Subtitle"))
            .border({ color: "#FFFfff", width: this.showBorder ? 2 : 0 })
            .fontSize(20 * this.Title_font_zoom)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 65 * this.Title_font_zoom })
            .position({ y: this.subTitle_y_offset })
            .opacity(this.subTitle_opacity)
            .animation(this.animateParam(300))
            .onAreaChange(() => {
              this.subTitle_y_offset = 0
              this.subTitle_opacity = 100
            })
            .fontColor(this.font_color)
            .animation(this.animateParam(0))
        }
        .position({ y: this.Title_top_margin + 20 })
        .width("100%")
        .border({ color: "#FFFFFF", width: this.showBorder ? 2 : 0 })
        .animation(this.animateParam(0))
        .padding({ left: 20 })

        // BIG TITLE ("STUFFS")

        WaterFlow({ scroller: this.scroller }) {

          FlowItem() {
          }.height(130)

          // TOP OF WATERFLOW

          FlowItem() {
            RelativeContainer() {
              Text(this.is_first_open ? $r('app.string.Welcome') : $r(this.Greetings_address))
                .fontSize(25)
                .fontWeight(FontWeight.Bolder)
                .position({ x: 20, y: 20 })
                .fontColor(this.font_color)
              // TITLE GREETINGS

              Row() {
                LinysSymbolButton({
                  image: $r('sys.symbol.plus'),
                  text: $r("app.string.Settings_block_Add"),
                  font_color: this.font_color,
                  trigger: this.block_add_is_open,
                  switch_to_arrow: this.block_add_is_open,
                })
                  .onClick(() => {
                    this.Color_scheme_edit_confirm = 0
                    this.block_settings_is_open = false
                    if (this.block_add_is_open) {
                      this.block_settings_height = 170
                      this.block_add_is_open = false
                    } else {
                      this.block_settings_height = 845
                      this.block_add_is_open = true
                      // ADD LENGTH
                    }
                  })

                LinysSymbolButton({
                  image: $r('sys.symbol.gearshape'),
                  text: $r("app.string.Settings_block_Settings"),
                  font_color: this.font_color,
                  trigger: this.block_settings_is_open,
                  switch_to_arrow: this.block_settings_is_open,
                })
                  .onClick(() => {
                    this.Color_scheme_edit_confirm = 0
                    this.block_add_is_open = false
                    if (this.block_settings_is_open) {
                      this.block_settings_height = 170
                      this.block_settings_is_open = false
                    } else {
                      this.block_settings_height = 1030
                      this.block_settings_is_open = true
                      // SETTINGS LENGTH
                    }
                  })
              }
              .padding({ left: 10, right: 10 })
              .position({ y: 60 })

              // Block Head Buttons

              Column({ space: 10 }) {
                // Settings
                Text($r("app.string.Settings_block_Settings"))
                  .offset({ y: this.block_settings_is_open ? 0 : 50 })
                  .visibility(this.block_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.block_settings_is_open ? 50 : 0))
                  .fontColor(this.font_color)
                  .fontSize(25)
                  .fontWeight(FontWeight.Bold)

                LinysLeftTitle({
                  text: $r("app.string.Settings_Content_Background"),
                  show: this.block_settings_is_open,
                  font_color: this.font_color,
                  delay: 100,
                })

                SegmentButton({
                  options: this.backdrop_tab_Options,
                  selectedIndexes: $backdrop_tab_choose
                })
                  .offset({ y: this.block_settings_is_open ? 0 : 50 })
                  .visibility(this.block_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.block_settings_is_open ? 150 : 0))

                LinysLeftTitle({
                  text: $r("app.string.Settings_Content_Blur_Radius"),
                  show: this.block_settings_is_open,
                  font_color: this.font_color,
                  delay: 200,
                })

                Slider({
                  style: SliderStyle.InSet,
                  min: 1,
                  max: 100,
                  value: this.Blur_radius
                })
                  .onChange((value: number, mode: SliderChangeMode) => {
                    this.Blur_radius = value
                    if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                      PreferencesTools.putValueOfKey(this.settings_db_name, "blur_radius", this.Blur_radius)
                    }
                  })
                  .offset({ y: this.block_settings_is_open ? 0 : 50 })
                  .visibility(this.block_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.block_settings_is_open ? 250 : 0))
                  .blockColor(this.block_background)
                  .selectedColor(this.font_color)

                LinysLeftTitle({
                  text: $r("app.string.Settings_Content_Min_Block_Size"),
                  show: this.block_settings_is_open,
                  font_color: this.font_color,
                  delay: 300,
                })

                Slider({
                  style: SliderStyle.InSet,
                  min: 300,
                  max: 1000,
                  value: this.Min_block_size
                })
                  .onChange((value: number, mode: SliderChangeMode) => {
                    if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                      this.Min_block_size = value
                      this.setWaterFlowLayout()
                      PreferencesTools.putValueOfKey(this.settings_db_name, "Min_block_size", this.Min_block_size)
                    }
                  })
                  .offset({ y: this.block_settings_is_open ? 0 : 50 })
                  .visibility(this.block_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.block_settings_is_open ? 350 : 0))
                  .blockColor(this.block_background)
                  .selectedColor(this.font_color)

                LinysRightExplanation({
                  text: $r("app.string.Settings_Content_Color_Scheme_Star"),
                  show: this.block_settings_is_open,
                  font_color: this.font_color,
                  max_lines: 3,
                  delay: 400,
                })

                LinysLeftTitle({
                  text: $r("app.string.Settings_Content_Color_Scheme_Light"),
                  show: this.block_settings_is_open,
                  font_color: this.font_color,
                  delay: 450,
                })

                TextArea({
                  placeholder: this.Color_scheme_light.toString(),
                  text: this.Color_scheme_light.toString()
                })
                  .onChange((value) => {
                    this.Color_scheme_edit_light = value
                  })
                  .height(81)
                  .textOverflow(TextOverflow.Ellipsis)
                  .offset({ y: this.block_settings_is_open ? 0 : 50 })
                  .visibility(this.block_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.block_settings_is_open ? 500 : 0))
                  .fontColor(this.font_color)

                LinysLeftTitle({
                  text: $r("app.string.Settings_Content_Color_Scheme_Dark"),
                  show: this.block_settings_is_open,
                  font_color: this.font_color,
                  delay: 550,
                })

                TextArea({
                  placeholder: this.Color_scheme_dark.toString(),
                  text: this.Color_scheme_dark.toString()
                })
                  .onChange((value) => {
                    this.Color_scheme_edit_dark = value
                  })
                  .height(81)
                  .textOverflow(TextOverflow.Ellipsis)
                  .offset({ y: this.block_settings_is_open ? 0 : 50 })
                  .visibility(this.block_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.block_settings_is_open ? 600 : 0))
                  .fontColor(this.font_color)

                LinysRightExplanation({
                  text: $r("app.string.Settings_Content_Color_Scheme_Description"),
                  show: this.block_settings_is_open,
                  font_color: this.font_color,
                  max_lines: 7,
                  delay: 650,
                })

                Button() {
                  Text($r("app.string.General_OK"))
                    .fontSize(15)
                    .fontColor(this.block_background)
                    .fontWeight(FontWeight.Bolder)
                }
                .width("100%")
                .padding(5)
                .backgroundColor(this.font_color)
                .onClick(() => {
                  this.setWaterFlowLayout()

                  PreferencesTools.putValueOfKey(this.settings_db_name, "Min_block_size", this.Min_block_size)

                  if (this.Color_scheme_edit_light != "") {
                    this.Color_scheme_light = this.Color_scheme_edit_light.split(",")
                  }
                  if (this.Color_scheme_edit_dark != "") {
                    this.Color_scheme_dark = this.Color_scheme_edit_dark.split(",")
                  }
                  this.updateKeyColors()
                  this.storeCurrentDesign()
                })
                .offset({ y: this.block_settings_is_open ? 0 : 50 })
                .visibility(this.block_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                .animation(this.animateParam(this.block_settings_is_open ? 700 : 0))
                .clickEffect({ level: ClickEffectLevel.LIGHT })

                LinysRightExplanation({
                  text: $r("app.string.Settings_Content_Color_Scheme_Got_Messy"),
                  show: this.block_settings_is_open,
                  font_color: this.font_color,
                  max_lines: 1,
                  delay: 750,
                })

                Button() {
                  Text(this.Color_scheme_edit_confirm == 0 ?
                  $r("app.string.General_RESET") : $r('app.string.General_One_More_Confirm'))
                    .fontSize(15)
                    .fontColor(this.Color_scheme_edit_confirm == 0 ? this.block_background : this.font_color)
                    .fontWeight(FontWeight.Bolder)
                }
                .width("100%")
                .padding(5)
                .backgroundColor(this.Color_scheme_edit_confirm == 0 ? this.font_color : this.block_background)
                .animation(this.animateParam(0))
                .clickEffect({ level: ClickEffectLevel.LIGHT })
                .offset({ y: this.block_settings_is_open ? 0 : 50 })
                .visibility(this.block_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                .animation(this.animateParam(this.block_settings_is_open ? 800 : 0))
                .onClick(() => {
                  // RESET SCHEME
                  if (this.Color_scheme_edit_confirm == 0) {
                    this.Color_scheme_edit_confirm = 1
                  } else if (this.Color_scheme_edit_confirm == 1) {
                    this.Color_scheme_edit_confirm = 0

                    this.Color_scheme_light = this.Color_scheme_light_default.split(",")
                    this.Color_scheme_dark = this.Color_scheme_dark_default.split(",")
                    this.Min_block_size = 450
                    this.Blur_radius = 25
                    this.updateKeyColors()
                    this.storeCurrentDesign()
                    this.setWaterFlowLayout()
                  }
                })
              }
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 20, right: 20 })
              .position({ y: 165 })
              .visibility(this.block_settings_is_open ? Visibility.Visible : Visibility.None)

              // Settings Content

              Column({ space: 10 }) {
                Text($r("app.string.Settings_block_Add"))
                  .fontSize(25)
                  .fontColor(this.font_color)
                  .fontWeight(FontWeight.Bold)
                  .offset({ y: this.block_add_is_open ? 0 : 50 })
                  .visibility(this.block_add_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.block_add_is_open ? 50 : 0))

                LinysLeftTitle({
                  text: $r("app.string.Add_Name_Title"),
                  show: this.block_add_is_open,
                  font_color: this.font_color,
                  delay: 100,
                })

                LinysTextArea({
                  placeholder: "=￣ω￣=",
                  text: this.Add_name_edit,
                  font_color: this.font_color,
                  show: this.block_add_is_open,
                  area_height: 39,
                  delay: 150
                })

                LinysLeftTitle({
                  text: $r("app.string.Add_Description"),
                  show: this.block_add_is_open,
                  font_color: this.font_color,
                  delay: 200,
                })

                LinysTextArea({
                  placeholder: "(〃￣︶￣)人(￣︶￣〃)",
                  text: this.Add_description_edit,
                  font_color: this.font_color,
                  show: this.block_add_is_open,
                  area_height: 81,
                  delay: 250
                })

                LinysLeftTitle({
                  text: $r("app.string.Add_Length"),
                  show: this.block_add_is_open,
                  font_color: this.font_color,
                  delay: 300,
                })

                Slider({
                  style: SliderStyle.InSet,
                  min: 200,
                  max: 400,
                  value: this.Add_Length
                })
                  .blockColor(this.block_background)
                  .selectedColor(this.font_color)
                  .offset({ y: this.block_add_is_open ? 0 : 50 })
                  .visibility(this.block_add_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.block_add_is_open ? 350 : 0))
                  .onChange((value: number, _mode: SliderChangeMode) => {
                    this.Add_Length = value
                    if (value < 270) {
                      this.Add_Length_Description = "app.string.Add_Length_Notice_Short"
                    } else if (value < 330) {
                      this.Add_Length_Description = "app.string.Add_Length_Notice_Medium"
                    } else {
                      this.Add_Length_Description = "app.string.Add_Length_Notice_Long"
                    }
                  })

                LinysRightExplanation({
                  text: $r(this.Add_Length_Description),
                  show: this.block_add_is_open,
                  font_color: this.font_color,
                  max_lines: 1,
                  delay: 400,
                })

                LinysLeftTitle({
                  text: $r("app.string.Add_Time_Limit"),
                  show: this.block_add_is_open,
                  font_color: this.font_color,
                  delay: 450,
                })

                Slider({
                  style: SliderStyle.InSet,
                  min: 1,
                  max: 367,
                  value: this.Add_Time_Limit
                })
                  .blockColor(this.block_background)
                  .selectedColor(this.font_color)
                  .offset({ y: this.block_add_is_open ? 0 : 50 })
                  .visibility(this.block_add_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.block_add_is_open ? 500 : 0))
                  .onChange((value: number, _mode: SliderChangeMode) => {
                    this.Add_Time_Limit = Math.round(value)
                    this.Add_Time_Limit_Description = "app.string.Add_Day"
                    if (value == 367) {
                      this.Add_Time_Limit_Description = "app.string.Add_Day_Unlimited"
                    }
                  })

                Row() {
                  TextInput({ text: String(this.Add_Time_Limit) })
                    .type(InputType.Number)
                    .onChange((value) => {
                      if (value == "") {
                      } else {
                        this.Add_Time_Limit = Math.round(Number(value))
                        this.Add_Time_Limit_Description = "app.string.Add_Day"
                        if (Number(value) >= 367) {
                          this.Add_Time_Limit_Description = "app.string.Add_Day_Unlimited"
                          this.Add_Time_Limit = 367
                        }
                      }
                    })
                    .offset({ y: this.block_add_is_open ? 0 : 50 })
                    .animation(this.animateParam(550))
                    .visibility(this.block_add_is_open && this.Add_Time_Limit != 367 ?
                    Visibility.Visible : Visibility.Hidden)
                    .layoutWeight(1)
                    .fontSize(15)
                    .fontWeight(FontWeight.Regular)
                    .fontColor(this.font_color)

                  Text($r(this.Add_Time_Limit_Description))
                    .offset({ y: this.block_add_is_open ? 0 : 50 })
                    .visibility(this.block_add_is_open ? Visibility.Visible : Visibility.Hidden)
                    .animation(this.animateParam(550))
                    .fontSize(15)
                    .fontColor(this.font_color)
                    .fontWeight(FontWeight.Regular)
                    .textAlign(TextAlign.End)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }

                // Select Time Slider Indicator

                LinysLeftTitle({
                  text: $r("app.string.Add_Target_Value"),
                  show: this.block_add_is_open,
                  font_color: this.font_color,
                  delay: 600,
                })

                Slider({
                  style: SliderStyle.InSet,
                  min: 1,
                  max: 1001,
                  value: this.Add_Value_Target
                })
                  .offset({ y: this.block_add_is_open ? 0 : 50 })
                  .visibility(this.block_add_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.block_add_is_open ? 650 : 0))
                  .onChange((value: number, _mode: SliderChangeMode) => {
                    this.Add_Value_Target = Math.round(value)
                    this.Add_Value_Target_Description = "app.string.Add_Value_Unit_Hour"
                    if (value == 1001) {
                      this.Add_Value_Target_Description = "app.string.Add_Value_Unlimited"
                    }
                  })
                  .blockColor(this.block_background)
                  .selectedColor(this.font_color)

                Row() {
                  TextInput({ text: String(this.Add_Value_Target) })
                    .type(InputType.Number)
                    .onChange((value) => {
                      if (value == "") {
                      } else {
                        this.Add_Value_Target = Math.round(Number(value))
                        this.Add_Value_Target_Description = "app.string.Add_Value_Unit_Hour"
                        if (Number(value) >= 1001) {
                          this.Add_Value_Target_Description = "app.string.Add_Value_Unlimited"
                          this.Add_Value_Target = 1001
                        }
                      }
                    })
                    .offset({ y: this.block_add_is_open ? 0 : 50 })
                    .animation(this.animateParam(700))
                    .visibility(this.block_add_is_open && this.Add_Value_Target != 1001 ?
                    Visibility.Visible : Visibility.Hidden)
                    .fontSize(15)
                    .fontWeight(FontWeight.Regular)
                    .fontColor(this.font_color)
                    .layoutWeight(1)

                  Text($r(this.Add_Value_Target_Description))
                    .offset({ y: this.block_add_is_open ? 0 : 50 })
                    .visibility(this.block_add_is_open ? Visibility.Visible : Visibility.Hidden)
                    .animation(this.animateParam(750))
                    .fontSize(15)
                    .fontColor(this.font_color)
                    .fontWeight(FontWeight.Regular)
                    .textAlign(TextAlign.End)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }

                // Select Value Indicator

                Button() {
                  Text($r("app.string.General_OK"))
                    .fontSize(15)
                    .fontColor(this.block_background)
                    .fontWeight(FontWeight.Bolder)
                    .animation(this.animateParam(0))
                }
                .offset({ y: this.block_add_is_open ? 0 : 50 })
                .visibility(this.block_add_is_open ? Visibility.Visible : Visibility.Hidden)
                .animation(this.animateParam(this.block_add_is_open ? 400 : 0))
                .clickEffect({ level: ClickEffectLevel.LIGHT })
                .width("100%")
                .padding(5)
                .backgroundColor(this.font_color)
                .onClick(() => {
                  if (this.Add_name_edit != "") {
                    // Save Card and Add

                    if (this.cards_name.includes(this.Add_name_edit)) {
                      // Name crash
                    } else {
                      this.cards_name.push(this.Add_name_edit)
                      if (this.Add_description_edit == "") {
                        console.log("empty desc")
                        this.cards_desc.push("喵 meow")
                      } else {
                        this.cards_desc.push(this.Add_description_edit)
                      }
                      this.cards_length.push(this.Add_Length)
                      this.cards_time_limit.push(this.Add_Time_Limit)
                      this.cards_target.push(this.Add_Value_Target)
                      this.cards_done.push(0)
                      this.cards_start.push(systemDateTime.getTime())
                      this.cards_end.push(systemDateTime.getTime() + 86400000 * this.Add_Time_Limit)
                      this.storeCards()

                      this.Add_name_edit = ""
                      this.Add_description_edit = ""
                    }
                  } else {

                  }
                })

              }
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 20, right: 20 })
              .position({ y: 165 })
              .visibility(this.block_add_is_open ? Visibility.Visible : Visibility.None)
              .animation(this.animateParam(0))

              // Add Content

            }
          }
          .width("100%")
          .height(this.block_settings_height)
          .borderRadius(16)
          .border({ width: 1, color: "#4D7A7A7A" })
          .backgroundEffect({
            radius: this.use_backdrop ? this.Blur_radius : 0,
            color: this.block_background
          })
          .backgroundColor(this.use_backdrop ? "#00000000" : this.Color_scheme[5])
          .animation(this.animateParam(0))

          // SETTINGS AND ADD BLOCK

          ForEach(this.cards_name, (_content: string, key: number) => {
            LinysBlock({
              waterflow_column_count: this.waterFlow_Columns,
              use_backdrop: this.use_backdrop,
              color_scheme: this.Color_scheme,
              Blur_radius: this.Blur_radius,
              font_color: this.font_color,
              screen_width: this.Screen_width,
              screen_height: this.Screen_height,
              card_expanding: this.card_expanding,
              last_expanded: this.last_expanded,
              remaining_days: this.card_remaining_days,
              card_slogan: this.card_slogan,
              index: key,
              timeout: 100 * key,
              name: this.cards_name[key],
              desc: this.cards_desc[key],
              card_length: this.cards_length[key],
              target: this.cards_target,
              done: this.cards_done[key],
              time_limit: this.cards_time_limit[key],
              start: this.cards_start[key],
              end: this.cards_end[key]
            })
          })

          FlowItem() {
            RelativeContainer() {
              Text($r("app.string.Encouragement"))
                .textAlign(TextAlign.End)
                .fontColor(this.font_color)
                .fontSize(30)
                .fontWeight(FontWeight.Bolder)
                .alignRules({
                  right: { anchor: "__container__", align: HorizontalAlign.End },
                  bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
                })
                .offset({ y: -40 })
            }.height("100%")
          }
          .animation(this.animateParam(0))
          .height(this.Screen_height)

          // ENCOURAGEMENT

        }
        .width("100%")
        .margin({ top: 90 })
        .border({ color: "#FFFfff", width: this.showBorder ? 2 : 0 })
        .opacity(this.block_opacity)
        .position({ y: this.block_y_offset + 20 })
        .columnsGap(10)
        .borderRadius(16)
        .edgeEffect(EdgeEffect.Spring)
        .onAreaChange(() => {
          this.block_y_offset = 0
          this.block_opacity = 100
        })
        .onScrollIndex((first) => {
          if (first == 0) {
            this.Title_top_margin = 90
            this.Title_font_zoom = 1
          } else if (first > 0) {
            this.Title_top_margin = 10
            this.Title_font_zoom = 0.7
          }
        })
        .animation(this.animateParam(400))

        .columnsTemplate(this.waterFlow_Layout)
        .rowsGap(10)
        .animation(this.animateParam(0))

        .onClick(() => {
          if (this.card_expanding != -1) {
            this.card_expanding = -1
          }
        })
        .padding({ left: 10, right: 10 })

        // MAIN BODY OF CARDS

        Scroll() {
          Column() {
            Row() {
            }
            .height((this.card_expanding == -1) ? this.Screen_height * 1 : this.Screen_height * 0.25)
            .animation({ delay: 50, duration: 350, curve: Curve.ExtremeDeceleration })

            // PLACEHOLDER

            WaterFlow() {
              FlowItem() {
                Column() {
                  Text(this.cards_name[this.last_expanded])
                    .fontSize(30)
                    .fontColor(this.font_color)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 6 })
                    .maxLines(1)
                    .textAlign(TextAlign.Start)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .offset({ y: (this.card_expanding == -1) ? 100 : 0 })
                    .visibility((this.card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                    .animation(this.animateParam(150))
                    .width("100%")
                  // TITLE

                  Row() {
                    Text(String(this.cards_done[this.last_expanded]))
                      .fontSize(50)
                      .fontColor(this.font_color)
                      .fontWeight(FontWeight.Bold)
                    Text("／" + (this.cards_target[this.card_expanding] == 1001 ?
                      " ∞ " : String(this.cards_target[this.card_expanding])))
                      .fontSize(16)
                      .fontColor(this.font_color)
                      .fontWeight(FontWeight.Medium)
                    Text($r('app.string.Add_Value_Unit_Hour'))
                      .fontSize(16)
                      .fontColor(this.font_color)
                      .fontWeight(FontWeight.Medium)
                  }
                  .offset({ y: (this.card_expanding == -1) ? 100 : 0 })
                  .visibility((this.card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                  .animation(this.animateParam(200))
                  .alignItems(VerticalAlign.Bottom)
                  .margin({ bottom: 14 })
                  .width("100%")

                  // BIG DIGITS

                  Text("“" + this.cards_desc[this.last_expanded] + "”")
                    .fontWeight(FontWeight.Medium)
                    .fontSize(16)
                    .fontColor(this.font_color)
                    .offset({ y: (this.card_expanding == -1) ? 100 : 0 })
                    .visibility((this.card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                    .animation(this.animateParam(250))
                    .width("100%")
                }
                .width("100%")
                .height("100%")
                .align(Alignment.Center)
              }
              .width("100%")
              .height(200)

              // BASIC INFO

              FlowItem() {
                Column() {
                  Gauge({
                    value: this.cards_target[this.last_expanded] == 1001 ?
                      500 : this.cards_done[this.last_expanded],
                    min: 0,
                    max: this.cards_target[this.last_expanded] == 1001 ? 999 : this.cards_target[this.last_expanded]
                  }) {
                    Column() {
                      Text(String(this.cards_target[this.last_expanded] == 1001 ?
                        50 : (this.cards_done[this.last_expanded] / this.cards_target[this.last_expanded])) + " %")
                        .fontWeight(FontWeight.Medium)
                        .fontSize(20)
                        .fontColor(this.font_color)
                        .textAlign(TextAlign.Center)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .maxLines(1)
                        .margin({ top: '34%' })
                      Text($r('app.string.Card_Progress_Done'))
                        .fontWeight(FontWeight.Medium)
                        .fontSize(16)
                        .fontColor(this.font_color)
                        .textAlign(TextAlign.Center)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .maxLines(1)
                    }
                    .height("100%")
                  }
                  .startAngle(225)
                  .endAngle(135)
                  .colors(new LinearGradient([
                    { color: "#D0e84026", offset: 0 },
                    { color: "#D0f7ce00", offset: 0.6 },
                    { color: "#D064bb5c", offset: 1 }
                  ]))
                  .strokeWidth(18)
                  .trackShadow({ radius: 7, offsetX: 7, offsetY: 7 })
                  .height(180)
                }
                .offset({ y: (this.card_expanding == -1) ? 100 : 10 })
                .visibility((this.card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                .alignItems(this.Screen_width - 40 > 600 ? HorizontalAlign.End : HorizontalAlign.Center)
                .animation(this.animateParam(350))
                .width("100%")
                .height("100%")
              }
              .width("100%")
              .height(200)

              // DONE GRAPH

              FlowItem() {
                Column() {
                  Text($r(this.card_slogan))
                    .offset({ y: (this.card_expanding == -1) ? 100 : 0 })
                    .visibility((this.card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                    .animation(this.animateParam(400))
                    .fontSize(22)
                    .maxLines(1)
                    .fontColor(this.font_color)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 15 })

                  Gauge({
                    value: this.cards_time_limit[this.last_expanded] == 367 ?
                      0.5 * this.cards_time_limit[this.last_expanded] + 1 : this.card_remaining_days,
                    min: 0, max: this.cards_time_limit[this.last_expanded]
                  }) {
                    Column() {
                      Text(String(
                        this.cards_time_limit[this.last_expanded] == 367 ?
                          50 : ((this.cards_end[this.last_expanded] - systemDateTime.getTime()) / 864000 /
                        this.cards_time_limit[this.last_expanded]).toFixed(2)
                      ) + " %")
                        .fontWeight(FontWeight.Medium)
                        .fontSize(20)
                        .fontColor(this.font_color)
                        .textAlign(TextAlign.Center)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .maxLines(1)
                        .margin({ top: '34%' })
                      Text($r('app.string.Card_Progress_Remaining_Time'))
                        .fontWeight(FontWeight.Medium)
                        .fontSize(16)
                        .fontColor(this.font_color)
                        .textAlign(TextAlign.Center)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .maxLines(1)
                    }
                    .height("100%")
                  }
                  .offset({ y: (this.card_expanding == -1) ? 100 : 0 })
                  .visibility((this.card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                  .animation(this.animateParam(450))
                  .indicator(null)
                  .startAngle(225)
                  .endAngle(135)
                  .colors(this.font_color)
                  .strokeWidth(18)
                  .trackShadow({ radius: 7, offsetX: 7, offsetY: 7 })
                  .height(180)
                }
                .alignItems(HorizontalAlign.Center)
                .width("100%")
                .height("100%")
              }
              .width("100%")
              .height(220)

              // TIME LEFT GRAPH

              FlowItem() {
                Column() {
                  Text($r("app.string.Card_Progress_Desc_Estimating"))
                    .fontSize(18)
                    .fontColor(this.font_color)
                    .margin({ bottom: 5 })
                  Row() {
                    Text(
                      this.card_remaining_days == 0 ? "1" : (

                        this.cards_time_limit[this.last_expanded] == 367 ||
                          this.cards_target[this.last_expanded] == 1001 ? " ∞ " :
                        String(
                          ((this.cards_target[this.last_expanded] - this.cards_done[this.last_expanded]) /
                          this.card_remaining_days).toFixed(4)
                        )
                      )

                    )
                      .fontSize(40)
                      .fontColor(this.font_color)
                      .fontWeight(FontWeight.Bold)
                    Text($r('app.string.Add_Value_Unit_Hour'))
                      .fontSize(16)
                      .fontColor(this.font_color)
                      .margin({ bottom: 6 })
                  }
                  .margin({ bottom: 5 })
                  .alignItems(VerticalAlign.Bottom)

                  Text($r('app.string.Card_Progress_Desc_Estimating_Hours'))
                    .fontSize(18)
                    .fontColor(this.font_color)
                    .textAlign(TextAlign.Center)
                }
                .alignItems(HorizontalAlign.Center)
                .offset({ y: (this.card_expanding == -1) ? 100 : 0 })
                .visibility((this.card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                .animation(this.animateParam(500))
                .width("100%")

                // PLAN ESTIMATED
              }
              .width("100%")
              .height(this.Screen_width - 40 > 600 ? 220 : 160)

              // EXPLANATION
            }
            .rowsGap(20)
            .borderRadius(16)
            .backgroundEffect({
              radius: this.use_backdrop ? this.Blur_radius : 0,
              color: this.use_backdrop ? this.Color_scheme[4] : this.Color_scheme[5]
            })
            .backgroundColor(this.use_backdrop ? "#00000000" : this.Color_scheme[5])
            .padding(24)
            .height(this.Screen_width - 40 > 600 ? this.Screen_height : 2 * this.Screen_height)
            .width(Math.min(this.Screen_width - 40, 600))
            .columnsTemplate(this.Screen_width - 40 > 600 ? "1fr 1fr" : "1fr")
            .border({ width: 1, color: "#4d7a7a7a" })

            // INFO
          }
          .width("100%")
          .alignItems(HorizontalAlign.Center)
          .onTouch((event) => {
            if (event.type == TouchType.Up) {
              if (event.target.area.globalPosition.y != undefined) {
                if (event.target.area.globalPosition.y > 100) {
                  this.card_expanding = -1
                }
              }
            }
          })
          .margin({ bottom: 40 })
        }
        .backgroundColor("#80000000")
        .opacity((this.card_expanding == -1) ? 0 : 1)
        .animation(this.animateParam(0))
        .visibility((this.card_expanding == -1) ? Visibility.None : Visibility.Visible)
        .animation((this.card_expanding == -1) ? this.animateParam(300) : { duration: 0 })
        .alignRules({
          center: { anchor: "__container__", align: VerticalAlign.Center },
          middle: { anchor: "__container__", align: HorizontalAlign.Center }
        })
        .width("100%")
        .height("100%")
        .onClick(() => {
          this.card_expanding = -1
        })
        .edgeEffect(EdgeEffect.Spring)

        // CARD POP UP

      }
      .onAreaChange((_o, n) => {
        /* DETERMINE SCREEN SIZE AND LAYOUT
         * */
        this.Screen_width = Number(n.width) + 20
        this.Screen_height = Number(n.height) + 30

        if (this.card_expanding == -1) {
          this.setWaterFlowLayout()
        }

        let hour = Number(Date().split(" ")[4].split(":")[0])
        if (hour < 5) {
          this.current_time_period = "Sleep"
        } else if (hour < 11) {
          this.current_time_period = "Morning"
        } else if (hour < 14) {
          this.current_time_period = "Noon"
        } else if (hour < 18) {
          this.current_time_period = "Afternoon"
        } else if (hour < 23) {
          this.current_time_period = "Evening"
        } else {
          this.current_time_period = "Sleep"
        }
        this.Greetings_address = "app.string.Greetings_" + this.current_time_period
        /* Determine current time period for Greetings
         * */
      })
      .border({ color: "#FFFFFF", width: this.showBorder ? 2 : 0 })

      // Body

      Row() {
      }
      .height("100%")
      .width("100%")
      .backgroundColor($r('app.color.start_window_background'))
      .opacity(this.cover_continue_opacity)
      .animation({ delay: 0, duration: 500, curve: Curve.ExtremeDeceleration })
      .visibility(this.Color_scheme.length == 0 ? Visibility.Visible : Visibility.None)
      .animation({ delay: 510, duration: 10 })
      .onAreaChange(()=>{
        setTimeout(()=>{
          this.cover_continue_opacity = 0
        },200)
      })

      // COVER CONTINUES

    }
    .backgroundColor($r('app.color.start_window_background'))

  }

  switch_use_backdrop(use_or_not: boolean) {
    this.use_backdrop = use_or_not
    this.font_color = this.use_backdrop ? this.Color_scheme[2] : this.Color_scheme[3]
    this.block_background = this.use_backdrop ? this.Color_scheme[4] : this.Color_scheme[5]
    PreferencesTools.putValueOfKey(this.settings_db_name, "use_backdrop", String(this.use_backdrop))
  }

  onChangeBackground() {
    if (this.backdrop_tab_choose[0] == 0) {
      this.switch_use_backdrop(false)
    } else {
      this.switch_use_backdrop(true)
    }
    this.setSegmentButtonOptions()
  }

  onColorModeChange() {
    // Load Colors
    this.readDesign()
  }

  onDirectionChange() {
  }

  onCardExpand() {
    if (this.card_expanding == -1) {
      this.setWaterFlowLayout()
      // setTimeout(()=>{
      //   this.scroller.scrollToIndex(this.last_expanded + 2, true, undefined,{extraOffset:LengthMetrics.vp(-175)})
      // },50)
    } else {
      // this.last_expanded = this.card_expanding
      // let expanding_column = (this.card_expanding + 3) % this.waterFlow_Columns - 1
      // if (expanding_column == -1){
      //   expanding_column = this.waterFlow_Columns - 1
      // }
      // this.waterFlow_Layout = "1fr "
      // setTimeout(()=>{
      //   this.scroller.scrollToIndex(this.last_expanded + 2, true)
      // },50)
      // console.log(this.card_expanding.toString())
    }
  }

  readDesign() {
    PreferencesTools.getValueOfKey(this.settings_db_name, "use_backdrop").then((result) => {
      if (result as string == "true") {
        this.use_backdrop = true
        this.backdrop_tab_choose = [1]
      } else {
        this.use_backdrop = false
        this.backdrop_tab_choose = [0]
      }
      // this.readColors()
    })
    PreferencesTools.getValueOfKey(this.settings_db_name, "color_scheme_light").then((result) => {
      this.Color_scheme_light = (result as string).split(",")
      PreferencesTools.getValueOfKey(this.settings_db_name, "color_scheme_dark").then((result) => {
        this.Color_scheme_dark = (result as string).split(",")
        this.updateKeyColors()
      })
    })
    PreferencesTools.getValueOfKey(this.settings_db_name, "Min_block_size").then((result) => {
      this.Min_block_size = (result as number)
      this.setWaterFlowLayout()
    })
    PreferencesTools.getValueOfKey(this.settings_db_name, "blur_radius").then((result) => {
      this.Blur_radius = result as number
    })
    PreferencesTools.getValueOfKey(this.settings_db_name, "APP_open_time").then((result) => {
      this.APP_open_time = result as number
    })
  }

  updateKeyColors() {
    if (this.currentColorMode == ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      this.Color_scheme = this.Color_scheme_light
    } else {
      this.Color_scheme = this.Color_scheme_dark
    }
    this.font_color = this.use_backdrop ? this.Color_scheme[2] : this.Color_scheme[3]
    this.block_background = this.use_backdrop ? this.Color_scheme[4] : this.Color_scheme[5]
    this.setSegmentButtonOptions()
  }

  setSegmentButtonOptions() {
    this.backdrop_tab_Options = SegmentButtonOptions.tab({
      buttons: [
        { text: $r("app.string.Settings_Content_Background_Color") },
        { text: $r("app.string.Settings_Content_Background_Image") }],
      fontColor: this.font_color,
      selectedFontColor: this.block_background,
      fontWeight: FontWeight.Medium,
      // backgroundColor: this.Color_scheme[1],
      selectedFontWeight: FontWeight.Bolder,
      selectedBackgroundColor: this.font_color
    })
  }

  setWaterFlowLayout() {
    this.waterFlow_Columns = 0
    this.waterFlow_Layout = ""
    this.cards_lengths_each_column = []
    for (let i = this.Screen_width; i > 0; i = i - this.Min_block_size) {
      this.waterFlow_Layout = this.waterFlow_Layout + "1fr "
      this.waterFlow_Columns += 1
      this.cards_lengths_each_column.push(0)
    }

    if (this.waterFlow_Columns == 0) {
      this.waterFlow_Columns = 1
      this.cards_lengths_each_column.push(300)
      // Total length of head and first head block
    } else if (this.waterFlow_Columns == 1) {
      this.cards_lengths_each_column[0] = 300
    } else {
      this.cards_lengths_each_column[0] = 130
      this.cards_lengths_each_column[1] = 170
    }
    /* Initialize WaterFlow layout according to screen width
         * */
  }

  storeCurrentDesign() {
    console.log(this.Color_scheme_light.toString() + ' light_qwq')
    console.log(this.Color_scheme_dark.toString() + ' dark_qwq')
    PreferencesTools.putValueOfKey(this.settings_db_name, "color_scheme_light",
      this.Color_scheme_light.toString())
    PreferencesTools.putValueOfKey(this.settings_db_name, "color_scheme_dark",
      this.Color_scheme_dark.toString())
    PreferencesTools.putValueOfKey(this.settings_db_name, "blur_radius", this.Blur_radius)
    PreferencesTools.putValueOfKey(this.settings_db_name, "Min_block_size", this.Min_block_size)
  }

  storeCards() {
    KVManagerTools.putValueOfKey("cards_name", this.cards_name.toString())
    KVManagerTools.putValueOfKey("cards_desc", this.cards_desc.toString())
    KVManagerTools.putValueOfKey("cards_length", this.cards_length.toString())
    KVManagerTools.putValueOfKey("cards_time_limit", this.cards_time_limit.toString())
    KVManagerTools.putValueOfKey("cards_target", this.cards_target.toString())
    KVManagerTools.putValueOfKey("cards_done", this.cards_done.toString())
    KVManagerTools.putValueOfKey("cards_start", this.cards_start.toString())
    KVManagerTools.putValueOfKey("cards_end", this.cards_end.toString())
  }

  animateParam(delay: number) {
    let ap: AnimateParam = { delay: delay, duration: 300, curve: Curve.ExtremeDeceleration }
    return ap
  }
}

@Component
struct LinysBlock {
  @Prop use_backdrop: boolean;
  @Prop color_scheme: string[];
  @Prop Blur_radius: number = 25;
  @Prop font_color: string;
  @Prop screen_width: number;
  @Prop screen_height: number;
  @Link card_expanding: number;
  @State block_color: string = this.color_scheme[4];
  @State y_offset: number = 50;
  @State block_opacity: number = 0;
  @State timeout: number = 0;
  @Prop index: number;
  @State card_pressed: boolean = false
  @Prop name: string;
  @Prop desc: string;
  @Prop card_length: number;
  @Prop time_limit: number;
  @Prop target: number[];
  @Prop done: number;
  @Prop start: number;
  @Prop end: number;
  @Link last_expanded: number;
  @Link remaining_days: number;
  @Link card_slogan: string;
  @State expanded_width: number = Math.min(500, this.screen_width - 40)
  @State waterflow_column_count: number = 0

  build() {
    FlowItem() {
      RelativeContainer() {
        Column() {
          Text(this.name)
            .fontSize(25)
            .fontColor(this.font_color)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 6 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          // BIG TITLE

          Row() {
            Text(String(this.done))
              .fontSize(50)
              .fontColor(this.font_color)
              .fontWeight(FontWeight.Bold)
            Text("／" + (this.target[this.index] == 1001 ? " ∞ " : String(this.target[this.index])))
              .fontSize(16)
              .fontColor(this.font_color)
            Text($r('app.string.Add_Value_Unit_Hour'))
              .fontSize(16)
              .fontColor(this.font_color)
          }
          .alignItems(VerticalAlign.Bottom)
          .margin({ bottom: 14 })
          .width("100%")

          // BIG DIGITS

          Row() {
            Text($r('app.string.Card_Days_Total'))
              .fontSize(14)
              .fontColor(this.font_color)
            Text((this.time_limit == 367 ? " ∞ " : String(this.time_limit)))
              .fontSize(14)
              .fontColor(this.font_color)
              .fontWeight(FontWeight.Bold)
            Text($r('app.string.Card_Days_Unit_Day'))
              .fontSize(14)
              .fontColor(this.font_color)
          }
          .width("100%")

          // TOTAL DAYS

          Row() {
            Text($r("app.string.Card_Days_Remaining"))
              .fontSize(14)
              .fontColor(this.font_color)
            Text(
              this.time_limit == 367 ? " ∞ " :
              String(
                ((this.end - systemDateTime.getTime()) / 86400000).toFixed(1)
              )
            )
              .fontSize(14)
              .fontColor(this.font_color)
              .fontWeight(FontWeight.Bold)
            Text($r('app.string.Card_Days_Unit_Day'))
              .fontSize(14)
              .fontColor(this.font_color)
          }
          .width("100%")

          // REMAINING DAYS

        }
        .brightness(this.card_pressed ? 0.94 : 1)
        .width("100%")

        .animation({ duration: 300, curve: Curve.ExtremeDeceleration })
        .alignItems(HorizontalAlign.Start)
        .borderRadius(16)
        .backgroundEffect({
          radius: this.use_backdrop ? this.Blur_radius : 0,
          color: this.use_backdrop ? this.color_scheme[4] : this.color_scheme[5]
        })
        .backgroundColor(this.use_backdrop ? "#00000000" : this.color_scheme[5])
        .padding(20)
        .border({ width: 1, color: "#4d7a7a7a" })
        .height("100%")
        .offset({ y: (this.card_expanding == this.index) ? 200 : 0 })
        .opacity((this.card_expanding == this.index) ? 0 : 1)
        .animation({ duration: 400, curve: Curve.ExtremeDeceleration })

        // CONTENTS
      }
      .padding(this.card_pressed ? 5 : 0)
      .width("100%")
      .height("100%")
      .animation({ duration: 300, curve: Curve.ExtremeDeceleration })
    }
    .offset({ y: this.y_offset })
    .opacity(this.block_opacity)
    .animation({
      delay: this.index > this.waterflow_column_count * 3 ? 200 : this.timeout + 400,
      duration: 300,
      curve: Curve.ExtremeDeceleration
    })

    .height(this.card_length)
    // .height((this.card_expanding == this.index)?
    // Math.max(700, 0.5 * this.screen_height) : this.card_length)
    .width("100%")
    .animation({ duration: 300, curve: Curve.ExtremeDeceleration })

    .onAreaChange(() => {
      this.y_offset = 0
      this.block_opacity = 100
      this.expanded_width = Math.min(500, this.screen_width - 40)
    })
    .onTouch((event: TouchEvent) => {
      if (event.type == TouchType.Down) {
        this.card_pressed = true
      } else if (event.type == TouchType.Up) {
        this.card_pressed = false
      }
    })
    .onClick((_event) => {
      if (this.card_expanding == this.index) {
        this.card_expanding = -1
      } else {
        this.card_expanding = this.index
        this.last_expanded = this.index
        this.remaining_days = Math.max(0, Number(((this.end - systemDateTime.getTime()) / 86400000).toFixed(4)))

        if (this.time_limit == 367) {
          this.card_slogan = "app.string.Card_Progress_Desc_Time_Ad_Astra_Abyssosque"
        } else if (this.remaining_days / this.time_limit > 0.6) {
          this.card_slogan = "app.string.Card_Progress_Desc_Time_Sufficient"
        } else if (this.remaining_days / this.time_limit > 0.4) {
          this.card_slogan = "app.string.Card_Progress_Desc_Time_OK"
        } else if (this.remaining_days > 0) {
          this.card_slogan = "app.string.Card_Progress_Desc_Time_Quick"
        } else {
          this.card_slogan = "app.string.Card_Progress_Desc_Over_Due"
        }
        console.log(this.name + " " + this.index.toString() + ": " + this.target.toString() + "_" +
        this.time_limit.toString())
      }
    })

  }
}

@Component
struct LinysSymbolButton {
  @Prop font_color: string;
  @Prop switch_to_arrow: boolean;
  @State image: Resource = $r('sys.symbol.plus')
  @State text: Resource | string = $r("app.string.Settings_block_Settings")
  @State image_size: number = 30
  @Prop trigger: boolean;

  build() {
    Column() {
      SymbolGlyph(this.switch_to_arrow ? $r("sys.symbol.chevron_down") : this.image)
        .fontSize(this.image_size)
        .fontColor([
          this.font_color as ResourceColor,
          this.font_color as ResourceColor,
          this.font_color as ResourceColor
        ])// .effectStrategy(1)
        .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), Number(this.trigger))

      Text(this.text)
        .margin({ top: 10 })
        .fontColor(this.font_color)
    }
    .padding(15)
    .backgroundColor(Color.Transparent)
    .borderRadius(8)
  }
}

@Component
struct LinysLeftTitle {
  @Prop font_color: string = "#FFFFFF"
  @Prop show: boolean = false
  @Prop delay: number = 0
  @State text: string | Resource = "喵"
  @State max_lines: number = 1

  build() {
    Text(this.text)
      .fontSize(15)
      .fontWeight(FontWeight.Bold)
      .offset({ y: this.show ? 0 : 50 })
      .visibility(this.show ? Visibility.Visible : Visibility.Hidden)
      .maxLines(this.max_lines)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .animation({ delay: this.delay, duration: 300, curve: Curve.ExtremeDeceleration })
      .fontColor(this.font_color)
      .animation({ duration: 300, curve: Curve.ExtremeDeceleration })
  }
}

@Component
struct LinysRightExplanation {
  @Prop font_color: string = "#FFFFFF"
  @Prop show: boolean = false
  @State delay: number = 0
  @Prop text: string | Resource = "喵"
  @State max_lines: number = 999

  build() {
    Text(this.text)
      .fontSize(15)
      .fontWeight(FontWeight.Regular)
      .textAlign(TextAlign.End)
      .width("100%")
      .maxLines(this.max_lines)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .offset({ y: this.show ? 0 : 50 })
      .visibility(this.show ? Visibility.Visible : Visibility.Hidden)
      .animation({ delay: this.delay, duration: 300, curve: Curve.ExtremeDeceleration })
      .fontColor(this.font_color)
      .animation({ duration: 300, curve: Curve.ExtremeDeceleration })
  }
}

@Component
struct LinysTextArea {
  @Link text: string
  @Prop show: boolean
  @State delay: number = 0
  @Prop font_color: string = "#FFFFFF"
  @State placeholder: string = "placehoooooolder!"
  @State area_height: number = 39

  build() {
    TextArea({ placeholder: this.placeholder, text: this.text })
      .fontColor(this.font_color)
      .onChange((value) => {
        this.text = value
      })
      .height(this.area_height)
      .textOverflow(TextOverflow.Ellipsis)
      .offset({ y: this.show ? 0 : 50 })
      .visibility(this.show ? Visibility.Visible : Visibility.Hidden)
      .animation(this.animateParam(this.show ? this.delay : 0))
  }

  animateParam(delay: number) {
    let ap: AnimateParam = { delay: delay, duration: 300, curve: Curve.ExtremeDeceleration }
    return ap
  }
}