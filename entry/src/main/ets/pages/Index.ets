import display from '@ohos.display';
import { SegmentButton, SegmentButtonOptions } from '@ohos.arkui.advanced.SegmentButton';
import { ConfigurationConstant } from '@kit.AbilityKit';
import KVManagerTools from '../blocks/KVManagerTools';
import { distributedKVStore } from '@kit.ArkData';
import { systemDateTime } from '@kit.BasicServicesKit';
import PreferencesTools from '../blocks/PreferencesTools';

@Entry
@Component
struct Index {
  @State ENVIRONMENT_bottom_avoid_height: number = Number(AppStorage.get<number>('bottomRectHeight') + "");
  @State ENVIRONMENT_screen_width: number = display.getDefaultDisplaySync().width
  @State ENVIRONMENT_screen_height: number = display.getDefaultDisplaySync().height
  @StorageProp('currentColorMode') @Watch('onColorModeChange') ENVIRONMENT_current_color_mode: number = 0
  @StorageProp('currentDirection') @Watch('onDirectionChange') ENVIRONMENT_current_direction: number = 1
  @State STATUS_top_card_settings_is_open: boolean = false
  @State STATUS_top_card_add_is_open: boolean = false
  @State STATUS_current_time_period: string = "Morning"
  @State @Watch('onCardExpand') STATUS_card_expanding: number = -1
  @State STATUS_card_index_of_last_expanded: number = -1
  @State DESIGN_use_backdrop: boolean = false;
  @State DESIGN_color_scheme_light_default: string = "#5D1E3928,#FFC1CFC6,#FFFFFFFF,#FF334C42,#B0263F0F,#FFE3ECE7"
  @State DESIGN_color_scheme_dark_default: string = "#B3243930,#FF1F2B26,#FFC1CFC6,#FFC1CFC6,#80090E0B,#FF3F5A4E"
  @State DESIGN_color_scheme_light: string[] = this.DESIGN_color_scheme_light_default.split(",")
  @State DESIGN_color_scheme_dark: string[] = this.DESIGN_color_scheme_dark_default.split(",")
  @State DESIGN_color_scheme: string[] = []
  @State DESIGN_cards_blur_radius: number = 25
  @State DESIGN_min_card_size: number = 450
  @State DESIGN_font_color: string = this.DESIGN_color_scheme[2]
  @State DESIGN_block_background_color: string = this.DESIGN_color_scheme[4]
  @State UI_is_first_open: boolean = true
  @State UI_waterFlow_Layout: string = ""
  @State UI_waterFlow_Columns: number = 0
  @State UI_waterFlow_firstScroll: boolean = true
  @State UI_Title_top_margin: number = 90
  @State UI_Title_font_zoom: number = 1.00
  @State UI_Title_y_offset: number = 50
  @State UI_Title_opacity: number = 0
  @State UI_subTitle_y_offset: number = 50
  @State UI_subTitle_opacity: number = 0
  @State UI_top_card_offset: number = 50
  @State UI_top_card_opacity: number = 0
  @State UI_top_card_height: number = 170
  @State UI_top_card_greetings_address: string = "app.string.Greetings_Morning"
  @State @Watch('onChangeBackground') UI_backdrop_choose: number[] = [0]
  // if UI_backdrop_choose == [0] then use Pure Color as background
  @State UI_backdrop_segment_button_options: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [
      { text: $r("app.string.Settings_Content_Background_Color") },
      { text: $r("app.string.Settings_Content_Background_Image") }],
    fontColor: this.DESIGN_font_color,
    selectedFontColor: this.DESIGN_block_background_color,
    fontWeight: FontWeight.Medium,
    // backgroundColor: this.Color_scheme[0],
    selectedFontWeight: FontWeight.Bolder,
    selectedBackgroundColor: this.DESIGN_font_color
  })
  @State UI_card_expanded_remaining_days: number = 0
  @State UI_card_expanded_slogan_of_time: string = "Card_Progress_Desc_Time_"
  @State UI_start_up_cover_continue_opacity: number = 1
  @State SETTINGS_color_scheme_edit_light: string = this.DESIGN_color_scheme_light.toString()
  @State SETTINGS_color_scheme_edit_dark: string = this.DESIGN_color_scheme_dark.toString()
  @State SETTINGS_reset_design_confirm: number = 0
  @State ADD_name: string = ""
  @State ADD_description: string = ""
  @State ADD_length: number = 200
  @State ADD_length_description: string = "app.string.Add_Length_Notice_Short"
  @State ADD_time_limit: number = 31
  @State ADD_time_limit_unit_or_description: string = "app.string.Add_Day"
  @State ADD_value_target: number = 233
  @State ADD_value_target_unit_or_description: string = "app.string.Add_Value_Unit_Hour"
  @State EDIT_name: string = ""
  @State EDIT_description: string = ""
  @State EDIT_length: number = 200
  @State EDIT_length_description: string = "app.string.Add_Length_Notice_Short"
  @State DATA_app_open_time: number = 0
  @State DATA_cards_name: string[] = []
  @State DATA_cards_desc: string[] = []
  @State DATA_cards_length: number[] = []
  @State DATA_cards_time_limit: number[] = []
  @State DATA_cards_target: number[] = []
  @State DATA_cards_done: number[] = []
  @State DATA_cards_start: number[] = []
  @State DATA_cards_end: number[] = []
  kvStore: distributedKVStore.SingleKVStore | undefined = undefined;
  scroller: Scroller = new Scroller()

  onPageShow() {
    console.log("OKK")
    PreferencesTools.getValueOfKey("meow").then((result) => {
      if (result == "no") {
        console.log("welcome first run")
        // First open app then put
        PreferencesTools.putValueOfKey("meow", "meow")
        KVManagerTools.putValueOfKey("use_backdrop", "false")
        KVManagerTools.putValueOfKey("color_scheme_light",
          this.DESIGN_color_scheme_light_default)
        KVManagerTools.putValueOfKey("color_scheme_dark",
          this.DESIGN_color_scheme_dark_default)
        KVManagerTools.putValueOfKey("blur_radius", "25")
        KVManagerTools.putValueOfKey("Min_block_size", this.DESIGN_min_card_size.toString())
        KVManagerTools.putValueOfKey("APP_open_time", this.DATA_app_open_time.toString())

        this.storeCards()

      } else {
        // Used before then directly load
        let temp: string[] = []
        this.UI_is_first_open = false
        KVManagerTools.getValueOfKey("cards_name").then((result) => {
          this.DATA_cards_name = (result as string).split(",")
          if (this.DATA_cards_name[0] == "") {
            this.DATA_cards_name = []
          }
          console.log(this.DATA_cards_name.toString() + "cat")
        })
        KVManagerTools.getValueOfKey("cards_desc").then((result) => {
          this.DATA_cards_desc = (result as string).split(",")
          if (this.DATA_cards_desc[0] == "") {
            this.DATA_cards_desc = []
          }
        })
        KVManagerTools.getValueOfKey("cards_length").then((result) => {
          temp = (result as string).split(",")
          for (let index = 0; index < temp.length; index++) {
            this.DATA_cards_length.push(Number(temp[index]))
          }
          if (temp[0] == "") {
            this.DATA_cards_length = []
          }

          console.log(this.DATA_cards_length.toString())
        })
        KVManagerTools.getValueOfKey("cards_time_limit").then((result) => {
          temp = (result as string).split(",")
          for (let index = 0; index < temp.length; index++) {
            this.DATA_cards_time_limit.push(Number(temp[index]))
          }
          if (temp[0] == "") {
            this.DATA_cards_time_limit = []
          }
        })
        KVManagerTools.getValueOfKey("cards_target").then((result) => {
          temp = (result as string).split(",")
          for (let index = 0; index < temp.length; index++) {
            this.DATA_cards_target.push(Number(temp[index]))
          }
          if (temp[0] == "") {
            this.DATA_cards_target = []
          }
        })
        KVManagerTools.getValueOfKey("cards_done").then((result) => {
          temp = (result as string).split(",")
          for (let index = 0; index < temp.length; index++) {
            this.DATA_cards_done.push(Number(temp[index]))
          }
          if (temp[0] == "") {
            this.DATA_cards_done = []
          }
        })
        KVManagerTools.getValueOfKey("cards_start").then((result) => {
          temp = (result as string).split(",")
          for (let index = 0; index < temp.length; index++) {
            this.DATA_cards_start.push(Number(temp[index]))
          }
          if (temp[0] == "") {
            this.DATA_cards_start = []
          }
        })
        KVManagerTools.getValueOfKey("cards_end").then((result) => {
          temp = (result as string).split(",")
          for (let index = 0; index < temp.length; index++) {
            this.DATA_cards_end.push(Number(temp[index]))
          }
          if (temp[0] == "") {
            this.DATA_cards_end = []
          }
        })
      }
      this.readDesign()
    })
    // load KVStore
    this.DATA_app_open_time += 1
  }

  onBackPress(): boolean | void {
    if (this.STATUS_card_expanding != -1) {
      this.STATUS_card_expanding = -1
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

      Row() {
      }
      .height("100%")
      .width("100%")
      .backgroundColor(this.UI_start_up_cover_continue_opacity == 0 ?
        (this.DESIGN_use_backdrop ? this.DESIGN_color_scheme[0] : this.DESIGN_color_scheme[1])
        : $r('app.color.start_window_background')
      )
      .animation({ duration: 300, curve: Curve.ExtremeDeceleration })

      // Backdrop Cover

      RelativeContainer() {

        Row() {
          Text($r("app.string.Entry_Title"))
            .fontSize(45 * this.UI_Title_font_zoom)
            .fontWeight(FontWeight.Bolder)
            .position({ y: this.UI_Title_y_offset })
            .opacity(this.UI_Title_opacity)
            .animation(this.animateParam(200))
            .onAreaChange(() => {
              this.UI_Title_opacity = 100
              this.UI_Title_y_offset = 0
            })
            .fontColor(this.DESIGN_font_color)
            .animation(this.animateParam(0))

          Text($r("app.string.Entry_Subtitle"))
            .fontSize(20 * this.UI_Title_font_zoom)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 65 * this.UI_Title_font_zoom })
            .position({ y: this.UI_subTitle_y_offset })
            .opacity(this.UI_subTitle_opacity)
            .animation(this.animateParam(300))
            .onAreaChange(() => {
              this.UI_subTitle_y_offset = 0
              this.UI_subTitle_opacity = 100
            })
            .fontColor(this.DESIGN_font_color)
            .animation(this.animateParam(0))
        }
        .position({ y: this.UI_Title_top_margin + 20 })
        .width("100%")
        .animation(this.animateParam(0))
        .padding({ left: 20 })

        // BIG TITLE ("STUFFS")

        WaterFlow({}) {

          FlowItem() {
          }.height(130)

          // TOP OF waterFlow

          FlowItem() {
            RelativeContainer() {
              Text(this.UI_is_first_open ? $r('app.string.Welcome') : $r(this.UI_top_card_greetings_address))
                .fontSize(25)
                .fontWeight(FontWeight.Bolder)
                .position({ x: 20, y: 20 })
                .fontColor(this.DESIGN_font_color)
              // TITLE GREETINGS

              Row() {
                LinysSymbolButton({
                  UI_image: $r('sys.symbol.plus'),
                  UI_text: $r("app.string.Settings_block_Add"),
                  DESIGN_font_color: this.DESIGN_font_color,
                  STATUS_trigger: this.STATUS_top_card_add_is_open,
                  STATUS_switch_to_arrow: this.STATUS_top_card_add_is_open,
                })
                  .onClick(() => {
                    this.SETTINGS_reset_design_confirm = 0
                    this.STATUS_top_card_settings_is_open = false
                    this.ADD_name = ""
                    this.ADD_description = ""
                    if (this.STATUS_top_card_add_is_open) {
                      this.UI_top_card_height = 170
                      this.STATUS_top_card_add_is_open = false
                    } else {
                      this.UI_top_card_height = 845
                      this.STATUS_top_card_add_is_open = true
                      // ADD LENGTH
                    }
                  })

                LinysSymbolButton({
                  UI_image: $r('sys.symbol.gearshape'),
                  UI_text: $r("app.string.Settings_block_Settings"),
                  DESIGN_font_color: this.DESIGN_font_color,
                  STATUS_trigger: this.STATUS_top_card_settings_is_open,
                  STATUS_switch_to_arrow: this.STATUS_top_card_settings_is_open,
                })
                  .onClick(() => {
                    this.SETTINGS_reset_design_confirm = 0
                    this.STATUS_top_card_add_is_open = false
                    if (this.STATUS_top_card_settings_is_open) {
                      this.UI_top_card_height = 170
                      this.STATUS_top_card_settings_is_open = false
                    } else {
                      this.UI_top_card_height = 1030
                      this.STATUS_top_card_settings_is_open = true
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
                  .offset({ y: this.STATUS_top_card_settings_is_open ? 0 : 50 })
                  .visibility(this.STATUS_top_card_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.STATUS_top_card_settings_is_open ? 50 : 0))
                  .fontColor(this.DESIGN_font_color)
                  .fontSize(25)
                  .fontWeight(FontWeight.Bold)

                LinysLeftTitle({
                  UI_text: $r("app.string.Settings_Content_Background"),
                  STATUS_show: this.STATUS_top_card_settings_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_delay: 100,
                })

                SegmentButton({
                  options: this.UI_backdrop_segment_button_options,
                  selectedIndexes: $UI_backdrop_choose
                })
                  .offset({ y: this.STATUS_top_card_settings_is_open ? 0 : 50 })
                  .visibility(this.STATUS_top_card_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.STATUS_top_card_settings_is_open ? 150 : 0))

                LinysLeftTitle({
                  UI_text: $r("app.string.Settings_Content_Blur_Radius"),
                  STATUS_show: this.STATUS_top_card_settings_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_delay: 200,
                })

                Slider({
                  style: SliderStyle.InSet,
                  min: 1,
                  max: 100,
                  value: this.DESIGN_cards_blur_radius
                })
                  .onChange((value: number, mode: SliderChangeMode) => {
                    this.DESIGN_cards_blur_radius = value
                    if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                      KVManagerTools.putValueOfKey("blur_radius", this.DESIGN_cards_blur_radius.toString())
                    }
                  })
                  .offset({ y: this.STATUS_top_card_settings_is_open ? 0 : 50 })
                  .visibility(this.STATUS_top_card_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.STATUS_top_card_settings_is_open ? 250 : 0))
                  .blockColor(this.DESIGN_block_background_color)
                  .selectedColor(this.DESIGN_font_color)

                LinysLeftTitle({
                  UI_text: $r("app.string.Settings_Content_Min_Block_Size"),
                  STATUS_show: this.STATUS_top_card_settings_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_delay: 300,
                })

                Slider({
                  style: SliderStyle.InSet,
                  min: 300,
                  max: 1000,
                  value: this.DESIGN_min_card_size
                })
                  .onChange((value: number, mode: SliderChangeMode) => {
                    if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                      this.DESIGN_min_card_size = value
                      this.setWaterFlowLayout()
                      KVManagerTools.putValueOfKey("Min_block_size", this.DESIGN_min_card_size.toString())
                    }
                  })
                  .offset({ y: this.STATUS_top_card_settings_is_open ? 0 : 50 })
                  .visibility(this.STATUS_top_card_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.STATUS_top_card_settings_is_open ? 350 : 0))
                  .blockColor(this.DESIGN_block_background_color)
                  .selectedColor(this.DESIGN_font_color)

                LinysRightExplanation({
                  UI_text: $r("app.string.Settings_Content_Color_Scheme_Star"),
                  STATUS_show: this.STATUS_top_card_settings_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_max_lines: 3,
                  UI_delay: 400,
                })

                LinysLeftTitle({
                  UI_text: $r("app.string.Settings_Content_Color_Scheme_Light"),
                  STATUS_show: this.STATUS_top_card_settings_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_delay: 450,
                })

                TextArea({
                  placeholder: this.DESIGN_color_scheme_light.toString(),
                  text: this.DESIGN_color_scheme_light.toString()
                })
                  .onChange((value) => {
                    this.SETTINGS_color_scheme_edit_light = value
                  })
                  .height(81)
                  .textOverflow(TextOverflow.Ellipsis)
                  .offset({ y: this.STATUS_top_card_settings_is_open ? 0 : 50 })
                  .visibility(this.STATUS_top_card_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.STATUS_top_card_settings_is_open ? 500 : 0))
                  .fontColor(this.DESIGN_font_color)

                LinysLeftTitle({
                  UI_text: $r("app.string.Settings_Content_Color_Scheme_Dark"),
                  STATUS_show: this.STATUS_top_card_settings_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_delay: 550,
                })

                TextArea({
                  placeholder: this.DESIGN_color_scheme_dark.toString(),
                  text: this.DESIGN_color_scheme_dark.toString()
                })
                  .onChange((value) => {
                    this.SETTINGS_color_scheme_edit_dark = value
                  })
                  .height(81)
                  .textOverflow(TextOverflow.Ellipsis)
                  .offset({ y: this.STATUS_top_card_settings_is_open ? 0 : 50 })
                  .visibility(this.STATUS_top_card_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.STATUS_top_card_settings_is_open ? 600 : 0))
                  .fontColor(this.DESIGN_font_color)

                LinysRightExplanation({
                  UI_text: $r("app.string.Settings_Content_Color_Scheme_Description"),
                  STATUS_show: this.STATUS_top_card_settings_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_max_lines: 7,
                  UI_delay: 650,
                })

                Button() {
                  Text($r("app.string.General_OK"))
                    .fontSize(15)
                    .fontColor(this.DESIGN_block_background_color)
                    .fontWeight(FontWeight.Bolder)
                }
                .width("100%")
                .padding(5)
                .backgroundColor(this.DESIGN_font_color)
                .onClick(() => {
                  this.setWaterFlowLayout()

                  KVManagerTools.putValueOfKey("Min_block_size", this.DESIGN_min_card_size.toString())

                  if (this.SETTINGS_color_scheme_edit_light != "") {
                    this.DESIGN_color_scheme_light = this.SETTINGS_color_scheme_edit_light.split(",")
                  }
                  if (this.SETTINGS_color_scheme_edit_dark != "") {
                    this.DESIGN_color_scheme_dark = this.SETTINGS_color_scheme_edit_dark.split(",")
                  }
                  this.updateKeyColors()
                  this.storeCurrentDesign()
                })
                .offset({ y: this.STATUS_top_card_settings_is_open ? 0 : 50 })
                .visibility(this.STATUS_top_card_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                .animation(this.animateParam(this.STATUS_top_card_settings_is_open ? 700 : 0))
                .clickEffect({ level: ClickEffectLevel.LIGHT })

                LinysRightExplanation({
                  UI_text: $r("app.string.Settings_Content_Color_Scheme_Got_Messy"),
                  STATUS_show: this.STATUS_top_card_settings_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_max_lines: 1,
                  UI_delay: 750,
                })

                Button() {
                  Text(this.SETTINGS_reset_design_confirm == 0 ?
                  $r("app.string.General_RESET") : $r('app.string.General_One_More_Confirm'))
                    .fontSize(15)
                    .fontColor(this.SETTINGS_reset_design_confirm == 0 ? this.DESIGN_block_background_color :
                    this.DESIGN_font_color)
                    .fontWeight(FontWeight.Bolder)
                }
                .width("100%")
                .padding(5)
                .backgroundColor(this.SETTINGS_reset_design_confirm == 0 ? this.DESIGN_font_color :
                this.DESIGN_block_background_color)
                .animation(this.animateParam(0))
                .clickEffect({ level: ClickEffectLevel.LIGHT })
                .offset({ y: this.STATUS_top_card_settings_is_open ? 0 : 50 })
                .visibility(this.STATUS_top_card_settings_is_open ? Visibility.Visible : Visibility.Hidden)
                .animation(this.animateParam(this.STATUS_top_card_settings_is_open ? 800 : 0))
                .onClick(() => {
                  // RESET SCHEME
                  if (this.SETTINGS_reset_design_confirm == 0) {
                    this.SETTINGS_reset_design_confirm = 1
                  } else if (this.SETTINGS_reset_design_confirm == 1) {
                    this.SETTINGS_reset_design_confirm = 0

                    this.DESIGN_color_scheme_light = this.DESIGN_color_scheme_light_default.split(",")
                    this.DESIGN_color_scheme_dark = this.DESIGN_color_scheme_dark_default.split(",")
                    this.DESIGN_min_card_size = 450
                    this.DESIGN_cards_blur_radius = 25
                    this.updateKeyColors()
                    this.storeCurrentDesign()
                    this.setWaterFlowLayout()
                  }
                })
              }
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 20, right: 20 })
              .position({ y: 165 })
              .visibility(this.STATUS_top_card_settings_is_open ? Visibility.Visible : Visibility.None)

              // Settings Content

              Column({ space: 10 }) {
                Text($r("app.string.Settings_block_Add"))
                  .fontSize(25)
                  .fontColor(this.DESIGN_font_color)
                  .fontWeight(FontWeight.Bold)
                  .offset({ y: this.STATUS_top_card_add_is_open ? 0 : 50 })
                  .visibility(this.STATUS_top_card_add_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.STATUS_top_card_add_is_open ? 50 : 0))

                LinysLeftTitle({
                  UI_text: $r("app.string.Add_Name_Title"),
                  STATUS_show: this.STATUS_top_card_add_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_delay: 100,
                })

                LinysTextArea({
                  UI_placeholder: "=￣ω￣=",
                  UI_text: this.ADD_name,
                  DESIGN_font_color: this.DESIGN_font_color,
                  STATUS_show: this.STATUS_top_card_add_is_open,
                  UI_area_height: 39,
                  UI_delay: 150
                })

                LinysLeftTitle({
                  UI_text: $r("app.string.Add_Description"),
                  STATUS_show: this.STATUS_top_card_add_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_delay: 200,
                })

                LinysTextArea({
                  UI_placeholder: "(〃￣︶￣)人(￣︶￣〃)",
                  UI_text: this.ADD_description,
                  DESIGN_font_color: this.DESIGN_font_color,
                  STATUS_show: this.STATUS_top_card_add_is_open,
                  UI_area_height: 81,
                  UI_delay: 250
                })

                LinysLeftTitle({
                  UI_text: $r("app.string.Add_Length"),
                  STATUS_show: this.STATUS_top_card_add_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_delay: 300,
                })

                Slider({
                  style: SliderStyle.InSet,
                  min: 200,
                  max: 400,
                  value: this.ADD_length
                })
                  .blockColor(this.DESIGN_block_background_color)
                  .selectedColor(this.DESIGN_font_color)
                  .offset({ y: this.STATUS_top_card_add_is_open ? 0 : 50 })
                  .visibility(this.STATUS_top_card_add_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.STATUS_top_card_add_is_open ? 350 : 0))
                  .onChange((value: number, _mode: SliderChangeMode) => {
                    this.ADD_length = value
                    if (value < 270) {
                      this.ADD_length_description = "app.string.Add_Length_Notice_Short"
                    } else if (value < 330) {
                      this.ADD_length_description = "app.string.Add_Length_Notice_Medium"
                    } else {
                      this.ADD_length_description = "app.string.Add_Length_Notice_Long"
                    }
                  })

                LinysRightExplanation({
                  UI_text: $r(this.ADD_length_description),
                  STATUS_show: this.STATUS_top_card_add_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_max_lines: 1,
                  UI_delay: 400,
                })

                LinysLeftTitle({
                  UI_text: $r("app.string.Add_Time_Limit"),
                  STATUS_show: this.STATUS_top_card_add_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_delay: 450,
                })

                Slider({
                  style: SliderStyle.InSet,
                  min: 1,
                  max: 367,
                  value: this.ADD_time_limit
                })
                  .blockColor(this.DESIGN_block_background_color)
                  .selectedColor(this.DESIGN_font_color)
                  .offset({ y: this.STATUS_top_card_add_is_open ? 0 : 50 })
                  .visibility(this.STATUS_top_card_add_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.STATUS_top_card_add_is_open ? 500 : 0))
                  .onChange((value: number, _mode: SliderChangeMode) => {
                    this.ADD_time_limit = Math.round(value)
                    this.ADD_time_limit_unit_or_description = "app.string.Add_Day"
                    if (value == 367) {
                      this.ADD_time_limit_unit_or_description = "app.string.Add_Day_Unlimited"
                    }
                  })

                Row() {
                  TextInput({ text: String(this.ADD_time_limit) })
                    .type(InputType.Number)
                    .onChange((value) => {
                      if (value == "") {
                      } else {
                        this.ADD_time_limit = Math.round(Number(value))
                        this.ADD_time_limit_unit_or_description = "app.string.Add_Day"
                        if (Number(value) >= 367) {
                          this.ADD_time_limit_unit_or_description = "app.string.Add_Day_Unlimited"
                          this.ADD_time_limit = 367
                        }
                      }
                    })
                    .offset({ y: this.STATUS_top_card_add_is_open ? 0 : 50 })
                    .animation(this.animateParam(550))
                    .visibility(this.STATUS_top_card_add_is_open && this.ADD_time_limit != 367 ?
                    Visibility.Visible : Visibility.Hidden)
                    .layoutWeight(1)
                    .fontSize(15)
                    .fontWeight(FontWeight.Regular)
                    .fontColor(this.DESIGN_font_color)

                  Text($r(this.ADD_time_limit_unit_or_description))
                    .offset({ y: this.STATUS_top_card_add_is_open ? 0 : 50 })
                    .visibility(this.STATUS_top_card_add_is_open ? Visibility.Visible : Visibility.Hidden)
                    .animation(this.animateParam(550))
                    .fontSize(15)
                    .fontColor(this.DESIGN_font_color)
                    .fontWeight(FontWeight.Regular)
                    .textAlign(TextAlign.End)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }

                // Select Time Slider Indicator

                LinysLeftTitle({
                  UI_text: $r("app.string.Add_Target_Value"),
                  STATUS_show: this.STATUS_top_card_add_is_open,
                  DESIGN_font_color: this.DESIGN_font_color,
                  UI_delay: 600,
                })

                Slider({
                  style: SliderStyle.InSet,
                  min: 1,
                  max: 1001,
                  value: this.ADD_value_target
                })
                  .offset({ y: this.STATUS_top_card_add_is_open ? 0 : 50 })
                  .visibility(this.STATUS_top_card_add_is_open ? Visibility.Visible : Visibility.Hidden)
                  .animation(this.animateParam(this.STATUS_top_card_add_is_open ? 650 : 0))
                  .onChange((value: number, _mode: SliderChangeMode) => {
                    this.ADD_value_target = Math.round(value)
                    this.ADD_value_target_unit_or_description = "app.string.Add_Value_Unit_Hour"
                    if (value == 1001) {
                      this.ADD_value_target_unit_or_description = "app.string.Add_Value_Unlimited"
                    }
                  })
                  .blockColor(this.DESIGN_block_background_color)
                  .selectedColor(this.DESIGN_font_color)

                Row() {
                  TextInput({ text: String(this.ADD_value_target) })
                    .type(InputType.Number)
                    .onChange((value) => {
                      if (value == "") {
                      } else {
                        this.ADD_value_target = Math.round(Number(value))
                        this.ADD_value_target_unit_or_description = "app.string.Add_Value_Unit_Hour"
                        if (Number(value) >= 1001) {
                          this.ADD_value_target_unit_or_description = "app.string.Add_Value_Unlimited"
                          this.ADD_value_target = 1001
                        }
                      }
                    })
                    .offset({ y: this.STATUS_top_card_add_is_open ? 0 : 50 })
                    .animation(this.animateParam(700))
                    .visibility(this.STATUS_top_card_add_is_open && this.ADD_value_target != 1001 ?
                    Visibility.Visible : Visibility.Hidden)
                    .fontSize(15)
                    .fontWeight(FontWeight.Regular)
                    .fontColor(this.DESIGN_font_color)
                    .layoutWeight(1)

                  Text($r(this.ADD_value_target_unit_or_description))
                    .offset({ y: this.STATUS_top_card_add_is_open ? 0 : 50 })
                    .visibility(this.STATUS_top_card_add_is_open ? Visibility.Visible : Visibility.Hidden)
                    .animation(this.animateParam(750))
                    .fontSize(15)
                    .fontColor(this.DESIGN_font_color)
                    .fontWeight(FontWeight.Regular)
                    .textAlign(TextAlign.End)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }

                // Select Value Indicator

                Button() {
                  Text($r("app.string.General_OK"))
                    .fontSize(15)
                    .fontColor(this.DESIGN_block_background_color)
                    .fontWeight(FontWeight.Bolder)
                    .animation(this.animateParam(0))
                }
                .offset({ y: this.STATUS_top_card_add_is_open ? 0 : 50 })
                .visibility(this.STATUS_top_card_add_is_open ? Visibility.Visible : Visibility.Hidden)
                .animation(this.animateParam(this.STATUS_top_card_add_is_open ? 400 : 0))
                .clickEffect({ level: ClickEffectLevel.LIGHT })
                .width("100%")
                .padding(5)
                .backgroundColor(this.DESIGN_font_color)
                .onClick(() => {
                  if (this.ADD_name != "") {
                    // Save Card and Add

                    if (this.DATA_cards_name.includes(this.ADD_name)) {
                      // Name crash
                    } else {
                      this.DATA_cards_name.push(this.ADD_name)
                      if (this.ADD_description == "") {
                        console.log("empty desc")
                        this.DATA_cards_desc.push("喵 meow")
                      } else {
                        this.DATA_cards_desc.push(this.ADD_description)
                      }
                      this.DATA_cards_length.push(this.ADD_length)
                      this.DATA_cards_time_limit.push(this.ADD_time_limit)
                      this.DATA_cards_target.push(this.ADD_value_target)
                      this.DATA_cards_done.push(0)
                      this.DATA_cards_start.push(systemDateTime.getTime())
                      this.DATA_cards_end.push(systemDateTime.getTime() + 86400000 * this.ADD_time_limit)
                      this.storeCards()

                      this.ADD_name = ""
                      this.ADD_description = ""
                    }
                  } else {

                  }
                })

              }
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 20, right: 20 })
              .position({ y: 165 })
              .visibility(this.STATUS_top_card_add_is_open ? Visibility.Visible : Visibility.None)
              .animation(this.animateParam(0))

              // Add Content

            }
          }
          .width("100%")
          .height(this.UI_top_card_height)
          .borderRadius(16)
          .border({ width: 1, color: "#4D7A7A7A" })
          .backgroundEffect({
            radius: this.DESIGN_use_backdrop ? this.DESIGN_cards_blur_radius : 0,
            color: this.DESIGN_block_background_color
          })
          .backgroundColor(this.DESIGN_use_backdrop ? "#00000000" : this.DESIGN_color_scheme[5])
          .animation(this.animateParam(0))

          // SETTINGS AND ADD BLOCK

          ForEach(this.DATA_cards_name, (_content: string, key: number) => {
            LinysBlock({
              ENVIRONMENT_waterFlow_column_count: this.UI_waterFlow_Columns,
              DESIGN_use_backdrop: this.DESIGN_use_backdrop,
              DESIGN_color_scheme: this.DESIGN_color_scheme,
              DESIGN_blur_radius: this.DESIGN_cards_blur_radius,
              DESIGN_font_color: this.DESIGN_font_color,
              ENVIRONMENT_screen_width: this.ENVIRONMENT_screen_width,
              ENVIRONMENT_screen_height: this.ENVIRONMENT_screen_height,
              STATUS_card_expanding: this.STATUS_card_expanding,
              STATUS_last_expanded: this.STATUS_card_index_of_last_expanded,
              DETAILS_remaining_days: this.UI_card_expanded_remaining_days,
              DETAILS_card_slogan: this.UI_card_expanded_slogan_of_time,
              index: key,
              UI_timeout: 100 * key,
              name: this.DATA_cards_name[key],
              desc: this.DATA_cards_desc[key],
              card_length: this.DATA_cards_length[key],
              target: this.DATA_cards_target,
              done: this.DATA_cards_done[key],
              time_limit: this.DATA_cards_time_limit[key],
              start: this.DATA_cards_start[key],
              end: this.DATA_cards_end[key],
              DETAILS_Edit_name_edit: this.EDIT_name,
              DETAILS_Edit_description_edit: this.EDIT_description,
              DETAILS_Edit_Length: this.EDIT_length,
              DETAILS_Edit_Length_Description: this.EDIT_length_description
            })

          })

          FlowItem() {
            RelativeContainer() {
              Text($r("app.string.Encouragement"))
                .textAlign(TextAlign.End)
                .fontColor(this.DESIGN_font_color)
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
          .height(this.ENVIRONMENT_screen_height)

          // ENCOURAGEMENT

        }
        .width("100%")
        .margin({ top: 90, bottom: 20 })
        .opacity(this.UI_top_card_opacity)
        .position({ y: this.UI_top_card_offset + 20 })
        .columnsGap(10)
        .borderRadius(16)
        .edgeEffect(EdgeEffect.Spring)
        .onAreaChange(() => {
          this.UI_top_card_offset = 0
          this.UI_top_card_opacity = 100
        })
        .onScrollIndex((first) => {
          if (first == 0) {
            this.UI_Title_top_margin = 90
            this.UI_Title_font_zoom = 1
          } else if (first > 0) {
            this.UI_Title_top_margin = 10
            this.UI_Title_font_zoom = 0.7
          }
        })
        .animation(this.animateParam(400))

        .columnsTemplate(this.UI_waterFlow_Layout)
        .rowsGap(10)
        .animation(this.animateParam(0))

        .onClick(() => {
          if (this.STATUS_card_expanding != -1) {
            this.STATUS_card_expanding = -1
          }
        })
        .padding({ left: 10, right: 10 })

        // MAIN BODY OF CARDS

        Scroll(this.scroller) {
          Column() {
            Row() {
            }
            .height((this.STATUS_card_expanding == -1) ? this.ENVIRONMENT_screen_height * 1 :
              this.ENVIRONMENT_screen_height * 0.25)
            .animation({ delay: 50, duration: 350, curve: Curve.ExtremeDeceleration })

            // PLACEHOLDER

            WaterFlow() {
              FlowItem() {
                Column() {
                  Text(this.DATA_cards_name[this.STATUS_card_index_of_last_expanded])
                    .fontSize(30)
                    .fontColor(this.DESIGN_font_color)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 6 })
                    .maxLines(1)
                    .textAlign(TextAlign.Start)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .offset({ y: (this.STATUS_card_expanding == -1) ? 100 : 0 })
                    .visibility((this.STATUS_card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                    .animation(this.animateParam(this.STATUS_card_expanding == -1 ? 0 : 150))
                    .width("100%")
                  // TITLE

                  Row() {
                    Text(String(this.DATA_cards_done[this.STATUS_card_index_of_last_expanded]))
                      .fontSize(50)
                      .fontColor(this.DESIGN_font_color)
                      .fontWeight(FontWeight.Bold)
                    Text("／" + (this.DATA_cards_target[this.STATUS_card_expanding] == 1001 ?
                      " ∞ " : String(this.DATA_cards_target[this.STATUS_card_expanding])))
                      .fontSize(16)
                      .fontColor(this.DESIGN_font_color)
                      .fontWeight(FontWeight.Medium)
                    Text($r('app.string.Add_Value_Unit_Hour'))
                      .fontSize(16)
                      .fontColor(this.DESIGN_font_color)
                      .fontWeight(FontWeight.Medium)
                  }
                  .offset({ y: (this.STATUS_card_expanding == -1) ? 100 : 0 })
                  .visibility((this.STATUS_card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                  .animation(this.animateParam(this.STATUS_card_expanding == -1 ? 0 : 200))
                  .alignItems(VerticalAlign.Bottom)
                  .margin({ bottom: 14 })
                  .width("100%")

                  // BIG DIGITS

                  Text("“" + this.DATA_cards_desc[this.STATUS_card_index_of_last_expanded] + "”")
                    .fontWeight(FontWeight.Medium)
                    .fontSize(16)
                    .fontColor(this.DESIGN_font_color)
                    .offset({ y: (this.STATUS_card_expanding == -1) ? 100 : 0 })
                    .visibility((this.STATUS_card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
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
                    value: this.DATA_cards_target[this.STATUS_card_index_of_last_expanded] == 1001 ?
                      500 : this.DATA_cards_done[this.STATUS_card_index_of_last_expanded],
                    min: 0,
                    max: this.DATA_cards_target[this.STATUS_card_index_of_last_expanded] == 1001 ? 999 :
                    this.DATA_cards_target[this.STATUS_card_index_of_last_expanded]
                  }) {
                    Column() {
                      Text(String(this.DATA_cards_target[this.STATUS_card_index_of_last_expanded] == 1001 ?
                        50 : (this.DATA_cards_done[this.STATUS_card_index_of_last_expanded] /
                        this.DATA_cards_target[this.STATUS_card_index_of_last_expanded])) + " %")
                        .fontWeight(FontWeight.Medium)
                        .fontSize(20)
                        .fontColor(this.DESIGN_font_color)
                        .textAlign(TextAlign.Center)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .maxLines(1)
                        .margin({ top: '34%' })
                      Text($r('app.string.Card_Progress_Done'))
                        .fontWeight(FontWeight.Medium)
                        .fontSize(16)
                        .fontColor(this.DESIGN_font_color)
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
                  .trackShadow({ radius: 7, offsetX: -7, offsetY: 7 })
                  .height(180)
                }
                .offset({ y: (this.STATUS_card_expanding == -1) ? 100 : 10 })
                .visibility((this.STATUS_card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                .alignItems(this.ENVIRONMENT_screen_width - 40 > 600 ? HorizontalAlign.End : HorizontalAlign.Center)
                .animation(this.animateParam(this.STATUS_card_expanding == -1 ? 0 : 350))
                .width("100%")
                .height("100%")
              }
              .width("100%")
              .height(200)

              // DONE GRAPH

              FlowItem() {
                Column() {
                  Text($r(this.UI_card_expanded_slogan_of_time))
                    .offset({ y: (this.STATUS_card_expanding == -1) ? 100 : 0 })
                    .visibility((this.STATUS_card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                    .animation(this.animateParam(this.STATUS_card_expanding == -1 ? 0 : 400))
                    .fontSize(22)
                    .maxLines(1)
                    .fontColor(this.DESIGN_font_color)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 15 })

                  Gauge({
                    value: this.DATA_cards_time_limit[this.STATUS_card_index_of_last_expanded] == 367 ?
                      0.5 * this.DATA_cards_time_limit[this.STATUS_card_index_of_last_expanded] + 1 :
                    this.UI_card_expanded_remaining_days,
                    min: 0, max: this.DATA_cards_time_limit[this.STATUS_card_index_of_last_expanded]
                  }) {
                    Column() {
                      Text(String(
                        this.DATA_cards_time_limit[this.STATUS_card_index_of_last_expanded] == 367 ?
                          50 :
                        ((this.DATA_cards_end[this.STATUS_card_index_of_last_expanded] - systemDateTime.getTime()) /
                          864000 /
                        this.DATA_cards_time_limit[this.STATUS_card_index_of_last_expanded]).toFixed(2)
                      ) + " %")
                        .fontWeight(FontWeight.Medium)
                        .fontSize(20)
                        .fontColor(this.DESIGN_font_color)
                        .textAlign(TextAlign.Center)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .maxLines(1)
                        .margin({ top: '34%' })
                      Text($r('app.string.Card_Progress_Remaining_Time'))
                        .fontWeight(FontWeight.Medium)
                        .fontSize(16)
                        .fontColor(this.DESIGN_font_color)
                        .textAlign(TextAlign.Center)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .maxLines(1)
                    }
                    .height("100%")
                  }
                  .offset({ y: (this.STATUS_card_expanding == -1) ? 100 : 0 })
                  .visibility((this.STATUS_card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                  .animation(this.animateParam(this.STATUS_card_expanding == -1 ? 0 : 450))
                  .indicator(null)
                  .startAngle(225)
                  .endAngle(135)
                  .colors(this.DESIGN_font_color)
                  .strokeWidth(18)
                  .trackShadow({ radius: 7, offsetX: -7, offsetY: 7 })
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
                    .fontColor(this.DESIGN_font_color)
                    .margin({ bottom: 5 })
                  Row() {
                    Text(
                      this.UI_card_expanded_remaining_days == 0 ? "1" : (

                        this.DATA_cards_time_limit[this.STATUS_card_index_of_last_expanded] == 367 ||
                          this.DATA_cards_target[this.STATUS_card_index_of_last_expanded] == 1001 ? " ∞ " :
                        String(
                          ((this.DATA_cards_target[this.STATUS_card_index_of_last_expanded] -
                          this.DATA_cards_done[this.STATUS_card_index_of_last_expanded]) /
                          this.UI_card_expanded_remaining_days).toFixed(4)
                        )
                      )

                    )
                      .fontSize(40)
                      .fontColor(this.DESIGN_font_color)
                      .fontWeight(FontWeight.Bold)
                    Text($r('app.string.Add_Value_Unit_Hour'))
                      .fontSize(16)
                      .fontColor(this.DESIGN_font_color)
                      .margin({ bottom: 6 })
                  }
                  .margin({ bottom: 5 })
                  .alignItems(VerticalAlign.Bottom)

                  Text($r('app.string.Card_Progress_Desc_Estimating_Hours'))
                    .fontSize(18)
                    .fontColor(this.DESIGN_font_color)
                    .textAlign(TextAlign.Center)
                }
                .alignItems(HorizontalAlign.Center)
                .offset({ y: (this.STATUS_card_expanding == -1) ? 100 : 0 })
                .visibility((this.STATUS_card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                .animation(this.animateParam(this.STATUS_card_expanding == -1 ? 0 : 500))
                .width("100%")

                // PLAN ESTIMATED
              }
              .width("100%")
              .height(this.ENVIRONMENT_screen_width - 40 > 600 ? 220 : 160)

              // EXPLANATION

              FlowItem() {
                Column({ space: 10 }) {
                  Text($r("app.string.Settings_block_Settings"))
                    .visibility((this.STATUS_card_expanding == -1) ? Visibility.Hidden : Visibility.Visible)
                    .offset({ y: this.STATUS_card_expanding != -1 ? 0 : 50 })
                    .animation(this.animateParam(550))
                    .fontSize(22)
                    .maxLines(1)
                    .fontColor(this.DESIGN_font_color)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 15 })

                  LinysLeftTitle({
                    UI_text: $r("app.string.Add_Name_Title"),
                    STATUS_show: this.STATUS_card_expanding != -1,
                    DESIGN_font_color: this.DESIGN_font_color,
                    UI_delay: 600,
                  })

                  TextArea({
                    placeholder: "=￣ω￣=",
                    text: this.DATA_cards_name[this.STATUS_card_index_of_last_expanded]
                  })
                    .fontColor(this.DESIGN_font_color)
                    .onChange((value) => {
                      this.EDIT_name = value
                    })
                    .height(39)
                    .textOverflow(TextOverflow.Ellipsis)

                  LinysLeftTitle({
                    UI_text: $r("app.string.Add_Description"),
                    STATUS_show: this.STATUS_card_expanding != -1,
                    DESIGN_font_color: this.DESIGN_font_color,
                    UI_delay: 0,
                  })

                  TextArea({
                    placeholder: "(〃￣︶￣)人(￣︶￣〃)",
                    text: this.DATA_cards_desc[this.STATUS_card_index_of_last_expanded]
                  })
                    .fontColor(this.DESIGN_font_color)
                    .onChange((value) => {
                      this.EDIT_description = value
                    })
                    .height(81)
                    .textOverflow(TextOverflow.Ellipsis)

                  LinysLeftTitle({
                    UI_text: $r("app.string.Add_Length"),
                    STATUS_show: this.STATUS_card_expanding != -1,
                    DESIGN_font_color: this.DESIGN_font_color,
                    UI_delay: 0,
                  })

                  Slider({
                    style: SliderStyle.InSet,
                    min: 200,
                    max: 400,
                    value: this.DATA_cards_length[this.STATUS_card_index_of_last_expanded]
                  })
                    .blockColor(this.DESIGN_block_background_color)
                    .selectedColor(this.DESIGN_font_color)
                    .onChange((value: number, _mode: SliderChangeMode) => {
                      this.EDIT_length = value
                      if (value < 270) {
                        this.EDIT_length_description = "app.string.Add_Length_Notice_Short"
                      } else if (value < 330) {
                        this.EDIT_length_description = "app.string.Add_Length_Notice_Medium"
                      } else {
                        this.EDIT_length_description = "app.string.Add_Length_Notice_Long"
                      }
                    })

                  LinysRightExplanation({
                    UI_text: $r(this.EDIT_length_description),
                    STATUS_show: this.STATUS_card_expanding != -1,
                    DESIGN_font_color: this.DESIGN_font_color,
                    UI_max_lines: 1,
                    UI_delay: 400,
                  })

                  Button() {
                    Text($r("app.string.General_OK"))
                      .fontSize(15)
                      .fontColor(this.DESIGN_block_background_color)
                      .fontWeight(FontWeight.Bolder)
                      .animation(this.animateParam(0))
                  }
                  .clickEffect({ level: ClickEffectLevel.LIGHT })
                  .width("100%")
                  .padding(5)
                  .backgroundColor(this.DESIGN_font_color)
                  .onClick(() => {
                    // Save Card and Add
                    this.DATA_cards_name[this.STATUS_card_index_of_last_expanded] = this.EDIT_name
                    if (this.EDIT_description == "") {
                      console.log("empty desc")
                      this.DATA_cards_desc[this.STATUS_card_index_of_last_expanded] = "喵 meow"
                    } else {
                      this.DATA_cards_desc[this.STATUS_card_index_of_last_expanded] = this.EDIT_description
                    }
                    this.DATA_cards_length[this.STATUS_card_index_of_last_expanded] = this.EDIT_length

                    this.storeCards()

                  })
                }
                .alignItems(HorizontalAlign.Start)
                .height("100%")

              }
              .width("100%")
              .height(320)

            }
            .rowsGap(20)
            .borderRadius(16)
            .backgroundEffect({
              radius: this.DESIGN_use_backdrop ? this.DESIGN_cards_blur_radius : 0,
              color: this.DESIGN_use_backdrop ? this.DESIGN_color_scheme[4] : this.DESIGN_color_scheme[5]
            })
            .backgroundColor(this.DESIGN_use_backdrop ? "#00000000" : this.DESIGN_color_scheme[5])
            .padding(this.ENVIRONMENT_screen_width - 40 > 600 ? 32 : 20)
            .height(this.ENVIRONMENT_screen_width - 40 > 600 ? 2 * this.ENVIRONMENT_screen_height :
              4 * this.ENVIRONMENT_screen_height)
            .width(Math.min(this.ENVIRONMENT_screen_width - 40, 600))
            .columnsTemplate(this.ENVIRONMENT_screen_width - 40 > 600 ? "1fr 1fr" : "1fr")
            .border({ width: 1, color: "#4d7a7a7a" })

            // INFO
          }
          .width("100%")
          .alignItems(HorizontalAlign.Center)
          .onTouch((event) => {
            if (event.type == TouchType.Up) {
              if (event.target.area.globalPosition.y != undefined) {
                if (event.target.area.globalPosition.y > 100) {
                  this.STATUS_card_expanding = -1
                }
              }
            }
          })
          .margin({ bottom: 40 })
        }
        .backgroundColor("#80000000")
        .opacity((this.STATUS_card_expanding == -1) ? 0 : 1)
        .animation(this.animateParam(0))
        .visibility((this.STATUS_card_expanding == -1) ? Visibility.None : Visibility.Visible)
        .animation((this.STATUS_card_expanding == -1) ? this.animateParam(300) : { duration: 0 })
        .alignRules({
          center: { anchor: "__container__", align: VerticalAlign.Center },
          middle: { anchor: "__container__", align: HorizontalAlign.Center }
        })
        .width("100%")
        .height("100%")
        .onClick(() => {
          this.STATUS_card_expanding = -1
          this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
        })
        .edgeEffect(EdgeEffect.Spring)

        // CARD POP UP

      }
      .onAreaChange((_o, n) => {
        /* DETERMINE SCREEN SIZE AND LAYOUT
         * */
        this.ENVIRONMENT_screen_width = Number(n.width) + 20
        this.ENVIRONMENT_screen_height = Number(n.height) + 30

        if (this.STATUS_card_expanding == -1) {
          this.setWaterFlowLayout()
        }

        let hour = Number(Date().split(" ")[4].split(":")[0])
        if (hour < 5) {
          this.STATUS_current_time_period = "Sleep"
        } else if (hour < 11) {
          this.STATUS_current_time_period = "Morning"
        } else if (hour < 14) {
          this.STATUS_current_time_period = "Noon"
        } else if (hour < 18) {
          this.STATUS_current_time_period = "Afternoon"
        } else if (hour < 23) {
          this.STATUS_current_time_period = "Evening"
        } else {
          this.STATUS_current_time_period = "Sleep"
        }
        this.UI_top_card_greetings_address = "app.string.Greetings_" + this.STATUS_current_time_period
        /* Determine current time period for Greetings
         * */
      })

      // Body

      Row() {
      }
      .height("100%")
      .width("100%")
      .backgroundColor($r('app.color.start_window_background'))
      .opacity(this.UI_start_up_cover_continue_opacity)
      .animation({ delay: 0, duration: 500, curve: Curve.ExtremeDeceleration })
      .visibility(this.DESIGN_color_scheme.length == 0 ? Visibility.Visible : Visibility.None)
      .animation({ delay: 510, duration: 10 })
      .onAreaChange(() => {
        setTimeout(() => {
          this.UI_start_up_cover_continue_opacity = 0
        }, 200)
      })

      // COVER CONTINUES

    }
    .backgroundColor($r('app.color.start_window_background'))

  }

  onChangeBackground() {
    if (this.UI_backdrop_choose[0] == 0) {
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
    if (this.STATUS_card_expanding == -1) {
      this.setWaterFlowLayout()
      // if collapsed
    } else {
      // if is going to expand
    }
  }

  readDesign() {
    KVManagerTools.getValueOfKey("use_backdrop").then((result) => {
      if (result as string == "true") {
        this.DESIGN_use_backdrop = true
        this.UI_backdrop_choose = [1]
        // In the future set backdrop index here if multiple backdrop images are supported
      } else {
        this.DESIGN_use_backdrop = false
        this.UI_backdrop_choose = [0]
      }
      // this.readColors()
    })
    KVManagerTools.getValueOfKey("color_scheme_light").then((result) => {
      this.DESIGN_color_scheme_light = (result as string).split(",")
      KVManagerTools.getValueOfKey("color_scheme_dark").then((result) => {
        this.DESIGN_color_scheme_dark = (result as string).split(",")
        this.updateKeyColors()
      })
    })
    KVManagerTools.getValueOfKey("Min_block_size").then((result) => {
      this.DESIGN_min_card_size = Number(result as string)
      this.setWaterFlowLayout()
    })
    KVManagerTools.getValueOfKey("blur_radius").then((result) => {
      this.DESIGN_cards_blur_radius = Number(result as string)
    })
    KVManagerTools.getValueOfKey("APP_open_time").then((result) => {
      this.DATA_app_open_time = Number(result as string)
    })
  }

  updateKeyColors() {
    if (this.ENVIRONMENT_current_color_mode == ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      this.DESIGN_color_scheme = this.DESIGN_color_scheme_light
    } else {
      this.DESIGN_color_scheme = this.DESIGN_color_scheme_dark
    }
    this.DESIGN_font_color = this.DESIGN_use_backdrop ? this.DESIGN_color_scheme[2] : this.DESIGN_color_scheme[3]
    this.DESIGN_block_background_color =
      this.DESIGN_use_backdrop ? this.DESIGN_color_scheme[4] : this.DESIGN_color_scheme[5]
    this.setSegmentButtonOptions()
  }

  switch_use_backdrop(use_or_not: boolean) {
    this.DESIGN_use_backdrop = use_or_not
    this.DESIGN_font_color = this.DESIGN_use_backdrop ? this.DESIGN_color_scheme[2] : this.DESIGN_color_scheme[3]
    this.DESIGN_block_background_color =
      this.DESIGN_use_backdrop ? this.DESIGN_color_scheme[4] : this.DESIGN_color_scheme[5]
    KVManagerTools.putValueOfKey("use_backdrop", String(this.DESIGN_use_backdrop))
  }

  setSegmentButtonOptions() {
    this.UI_backdrop_segment_button_options = SegmentButtonOptions.tab({
      buttons: [
        { text: $r("app.string.Settings_Content_Background_Color") },
        { text: $r("app.string.Settings_Content_Background_Image") }],
      fontColor: this.DESIGN_font_color,
      selectedFontColor: this.DESIGN_block_background_color,
      fontWeight: FontWeight.Medium,
      // backgroundColor: this.Color_scheme[1],
      selectedFontWeight: FontWeight.Bolder,
      selectedBackgroundColor: this.DESIGN_font_color
    })
  }

  setWaterFlowLayout() {
    this.UI_waterFlow_Columns = 0
    this.UI_waterFlow_Layout = ""
    for (let i = this.ENVIRONMENT_screen_width; i > 0; i = i - this.DESIGN_min_card_size) {
      this.UI_waterFlow_Layout = this.UI_waterFlow_Layout + "1fr "
      this.UI_waterFlow_Columns += 1
    }

    if (this.UI_waterFlow_Columns == 0) {
      this.UI_waterFlow_Columns = 1
      // Total length of head and first head block
    }
    /* Initialize WaterFlow layout according to screen width
         * */
  }

  storeCurrentDesign() {
    console.log(this.DESIGN_color_scheme_light.toString() + ' light_qwq')
    console.log(this.DESIGN_color_scheme_dark.toString() + ' dark_qwq')
    KVManagerTools.putValueOfKey("color_scheme_light",
      this.DESIGN_color_scheme_light.toString())
    KVManagerTools.putValueOfKey("color_scheme_dark",
      this.DESIGN_color_scheme_dark.toString())
    KVManagerTools.putValueOfKey("blur_radius", this.DESIGN_cards_blur_radius.toString())
    KVManagerTools.putValueOfKey("Min_block_size", this.DESIGN_min_card_size.toString())
  }

  storeCards() {
    KVManagerTools.putValueOfKey("cards_name", this.DATA_cards_name.toString())
    KVManagerTools.putValueOfKey("cards_desc", this.DATA_cards_desc.toString())
    KVManagerTools.putValueOfKey("cards_length", this.DATA_cards_length.toString())
    KVManagerTools.putValueOfKey("cards_time_limit", this.DATA_cards_time_limit.toString())
    KVManagerTools.putValueOfKey("cards_target", this.DATA_cards_target.toString())
    KVManagerTools.putValueOfKey("cards_done", this.DATA_cards_done.toString())
    KVManagerTools.putValueOfKey("cards_start", this.DATA_cards_start.toString())
    KVManagerTools.putValueOfKey("cards_end", this.DATA_cards_end.toString())
  }

  animateParam(delay: number) {
    let ap: AnimateParam = { delay: delay, duration: 300, curve: Curve.ExtremeDeceleration }
    return ap
  }
}

@Component
struct LinysBlock {
  @Prop ENVIRONMENT_screen_width: number;
  @Prop ENVIRONMENT_screen_height: number;
  @State ENVIRONMENT_expanded_width: number = Math.min(500, this.ENVIRONMENT_screen_width - 40)
  @State ENVIRONMENT_waterFlow_column_count: number = 0
  @Link STATUS_card_expanding: number;
  @Link STATUS_last_expanded: number;
  @Prop DESIGN_use_backdrop: boolean;
  @Prop DESIGN_color_scheme: string[];
  @Prop DESIGN_blur_radius: number = 25;
  @Prop DESIGN_font_color: string;
  @State DESIGN_block_color: string = this.DESIGN_color_scheme[4];
  @State UI_y_offset: number = 50;
  @State UI_block_opacity: number = 0;
  @State UI_timeout: number = 0;
  @State UI_card_pressed: boolean = false
  @Link DETAILS_remaining_days: number;
  @Link DETAILS_card_slogan: string;
  @Link DETAILS_Edit_Length_Description: string;
  @Link DETAILS_Edit_name_edit: string;
  @Link DETAILS_Edit_description_edit: string;
  @Link DETAILS_Edit_Length: number;
  @Prop index: number;
  @Prop name: string;
  @Prop desc: string;
  @Prop card_length: number;
  @Prop time_limit: number;
  @Prop target: number[];
  @Prop done: number;
  @Prop start: number;
  @Prop end: number;

  build() {
    FlowItem() {
      RelativeContainer() {
        Column() {
          Text(this.name)
            .fontSize(25)
            .fontColor(this.DESIGN_font_color)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 6 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          // BIG TITLE

          Row() {
            Text(String(this.done))
              .fontSize(50)
              .fontColor(this.DESIGN_font_color)
              .fontWeight(FontWeight.Bold)
            Text("／" + (this.target[this.index] == 1001 ? " ∞ " : String(this.target[this.index])))
              .fontSize(16)
              .fontColor(this.DESIGN_font_color)
            Text($r('app.string.Add_Value_Unit_Hour'))
              .fontSize(16)
              .fontColor(this.DESIGN_font_color)
          }
          .alignItems(VerticalAlign.Bottom)
          .margin({ bottom: 14 })
          .width("100%")

          // BIG DIGITS

          Row() {
            Text($r('app.string.Card_Days_Total'))
              .fontSize(14)
              .fontColor(this.DESIGN_font_color)
            Text((this.time_limit == 367 ? " ∞ " : String(this.time_limit)))
              .fontSize(14)
              .fontColor(this.DESIGN_font_color)
              .fontWeight(FontWeight.Bold)
            Text($r('app.string.Card_Days_Unit_Day'))
              .fontSize(14)
              .fontColor(this.DESIGN_font_color)
          }
          .width("100%")

          // TOTAL DAYS

          Row() {
            Text($r("app.string.Card_Days_Remaining"))
              .fontSize(14)
              .fontColor(this.DESIGN_font_color)
            Text(
              this.time_limit == 367 ? " ∞ " :
              String(
                ((this.end - systemDateTime.getTime()) / 86400000).toFixed(1)
              )
            )
              .fontSize(14)
              .fontColor(this.DESIGN_font_color)
              .fontWeight(FontWeight.Bold)
            Text($r('app.string.Card_Days_Unit_Day'))
              .fontSize(14)
              .fontColor(this.DESIGN_font_color)
          }
          .width("100%")

          // REMAINING DAYS

        }
        .brightness(this.UI_card_pressed ? 0.94 : 1)
        .width("100%")

        .animation({ duration: 300, curve: Curve.ExtremeDeceleration })
        .alignItems(HorizontalAlign.Start)
        .borderRadius(16)
        .backgroundEffect({
          radius: this.DESIGN_use_backdrop ? this.DESIGN_blur_radius : 0,
          color: this.DESIGN_use_backdrop ? this.DESIGN_color_scheme[4] : this.DESIGN_color_scheme[5]
        })
        .backgroundColor(this.DESIGN_use_backdrop ? "#00000000" : this.DESIGN_color_scheme[5])
        .padding(20)
        .border({ width: 1, color: "#4d7a7a7a" })
        .height("100%")
        .offset({ y: (this.STATUS_card_expanding == this.index) ? 200 : 0 })
        .opacity((this.STATUS_card_expanding == this.index) ? 0 : 1)
        .animation({ duration: 400, curve: Curve.ExtremeDeceleration })

        // CONTENTS
      }
      .padding(this.UI_card_pressed ? 5 : 0)
      .width("100%")
      .height("100%")
      .animation({ duration: 300, curve: Curve.ExtremeDeceleration })
    }
    .offset({ y: this.UI_y_offset })
    .opacity(this.UI_block_opacity)
    .animation({
      delay: this.index > this.ENVIRONMENT_waterFlow_column_count * 2.5 ? 200 : this.UI_timeout + 300,
      duration: 300,
      curve: Curve.ExtremeDeceleration
    })

    .height(this.card_length)
    // .height((this.card_expanding == this.index)?
    // Math.max(700, 0.5 * this.screen_height) : this.card_length)
    .width("100%")
    .animation({ duration: 300, curve: Curve.ExtremeDeceleration })

    .onAreaChange(() => {
      this.UI_y_offset = 0
      this.UI_block_opacity = 100
      this.ENVIRONMENT_expanded_width = Math.min(500, this.ENVIRONMENT_screen_width - 40)
    })
    .onTouch((event: TouchEvent) => {
      if (event.type == TouchType.Down) {
        this.UI_card_pressed = true
      } else if (event.type == TouchType.Up) {
        this.UI_card_pressed = false
      }
    })
    .onClick((_event) => {
      if (this.STATUS_card_expanding == this.index) {
        this.STATUS_card_expanding = -1
      } else {
        this.STATUS_card_expanding = this.index
        this.STATUS_last_expanded = this.index
        this.DETAILS_remaining_days = Math.max(0, Number(((this.end - systemDateTime.getTime()) / 86400000).toFixed(4)))

        if (this.time_limit == 367) {
          this.DETAILS_card_slogan = "app.string.Card_Progress_Desc_Time_Ad_Astra_Abyssosque"
        } else if (this.DETAILS_remaining_days / this.time_limit > 0.6) {
          this.DETAILS_card_slogan = "app.string.Card_Progress_Desc_Time_Sufficient"
        } else if (this.DETAILS_remaining_days / this.time_limit > 0.4) {
          this.DETAILS_card_slogan = "app.string.Card_Progress_Desc_Time_OK"
        } else if (this.DETAILS_remaining_days > 0) {
          this.DETAILS_card_slogan = "app.string.Card_Progress_Desc_Time_Quick"
        } else {
          this.DETAILS_card_slogan = "app.string.Card_Progress_Desc_Over_Due"
        }
        console.log(this.name + " " + this.index.toString() + ": " + this.target.toString() + "_" +
        this.time_limit.toString())
      }
      this.DETAILS_Edit_name_edit = this.name
      this.DETAILS_Edit_description_edit = this.desc
      this.DETAILS_Edit_Length = this.card_length

      if (this.card_length < 270) {
        this.DETAILS_Edit_Length_Description = "app.string.Add_Length_Notice_Short"
      } else if (this.card_length < 330) {
        this.DETAILS_Edit_Length_Description = "app.string.Add_Length_Notice_Medium"
      } else {
        this.DETAILS_Edit_Length_Description = "app.string.Add_Length_Notice_Long"
      }
    })

  }
}

@Component
struct LinysSymbolButton {
  @Prop STATUS_switch_to_arrow: boolean;
  @Prop STATUS_trigger: boolean;
  @Prop DESIGN_font_color: string;
  @State UI_image: Resource = $r('sys.symbol.plus')
  @State UI_text: Resource | string = $r("app.string.Settings_block_Settings")
  @State UI_image_size: number = 30

  build() {
    Column() {
      SymbolGlyph(this.STATUS_switch_to_arrow ? $r("sys.symbol.chevron_down") : this.UI_image)
        .fontSize(this.UI_image_size)
        .fontColor([
          this.DESIGN_font_color as ResourceColor,
          this.DESIGN_font_color as ResourceColor,
          this.DESIGN_font_color as ResourceColor
        ])// .effectStrategy(1)
        .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), Number(this.STATUS_trigger))

      Text(this.UI_text)
        .margin({ top: 10 })
        .fontColor(this.DESIGN_font_color)
    }
    .padding(15)
    .backgroundColor(Color.Transparent)
    .borderRadius(8)
  }
}

@Component
struct LinysLeftTitle {
  @Prop DESIGN_font_color: string = "#FFFFFF"
  @Prop STATUS_show: boolean = false
  @Prop UI_delay: number = 0
  @State UI_text: string | Resource = "喵"
  @State UI_max_lines: number = 1

  build() {
    Text(this.UI_text)
      .fontSize(15)
      .fontWeight(FontWeight.Bold)
      .offset({ y: this.STATUS_show ? 0 : 50 })
      .visibility(this.STATUS_show ? Visibility.Visible : Visibility.Hidden)
      .maxLines(this.UI_max_lines)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .animation({ delay: this.UI_delay, duration: 300, curve: Curve.ExtremeDeceleration })
      .fontColor(this.DESIGN_font_color)
      .animation({ duration: 300, curve: Curve.ExtremeDeceleration })
  }
}

@Component
struct LinysRightExplanation {
  @Prop STATUS_show: boolean = false
  @Prop DESIGN_font_color: string = "#FFFFFF"
  @State UI_delay: number = 0
  @Prop UI_text: string | Resource = "喵"
  @State UI_max_lines: number = 999

  build() {
    Text(this.UI_text)
      .fontSize(15)
      .fontWeight(FontWeight.Regular)
      .textAlign(TextAlign.End)
      .width("100%")
      .maxLines(this.UI_max_lines)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .offset({ y: this.STATUS_show ? 0 : 50 })
      .visibility(this.STATUS_show ? Visibility.Visible : Visibility.Hidden)
      .animation({ delay: this.UI_delay, duration: 300, curve: Curve.ExtremeDeceleration })
      .fontColor(this.DESIGN_font_color)
      .animation({ duration: 300, curve: Curve.ExtremeDeceleration })
  }
}

@Component
struct LinysTextArea {
  @Prop STATUS_show: boolean
  @Prop DESIGN_font_color: string = "#FFFFFF"
  @Link UI_text: string
  @State UI_delay: number = 0
  @State UI_placeholder: string = "placeholder!"
  @State UI_area_height: number = 39

  build() {
    TextArea({ placeholder: this.UI_placeholder, text: this.UI_text })
      .fontColor(this.DESIGN_font_color)
      .onChange((value) => {
        this.UI_text = value
      })
      .height(this.UI_area_height)
      .textOverflow(TextOverflow.Ellipsis)
      .offset({ y: this.STATUS_show ? 0 : 50 })
      .visibility(this.STATUS_show ? Visibility.Visible : Visibility.Hidden)
      .animation(this.animateParam(this.STATUS_show ? this.UI_delay : 0))
  }

  animateParam(delay: number) {
    let ap: AnimateParam = { delay: delay, duration: 300, curve: Curve.ExtremeDeceleration }
    return ap
  }
}