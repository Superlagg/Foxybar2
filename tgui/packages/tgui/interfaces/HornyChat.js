/* eslint-disable react/no-danger */
// 80 characters is not big enough for my yiff yiff
/* eslint-disable max-len */
import { useBackend, useLocalState } from '../backend';
import { toFixed } from 'common/math';
import { multiline } from 'common/string';
import {
  AnimatedNumber,
  Box,
  Button,
  Dropdown,
  Input,
  Tooltip,
  Section,
  LabeledList,
  NoticeBox,
  NumberInput,
  Icon,
  Knob,
  Stack,
  Fragment,
  Table,
  ToggleBox,
} from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';
import { marked } from 'marked';
import { sanitizeText } from '../sanitize';

/*
  Welcome to HornyChat, how horny are you?
    I yiffed a bowl of nails for breakfast, without any milk.

  This is the preferecnes page for HornyChat, you can set your preferences here.
  There are three tabs, "Profile Pics", "Message Appearance", and "Preview".

  Profile Pics:
    Sevreral lines for profile pics
    Column names:
      - Copy
      - Message Mode
      - Host
      - Filename
      - Preview
      - Clear
    Each line will have:
      - A copy button
        - Will add in a paste button for the rest of the entries
      - The message mode that will trigger the profile pic
      - A dropdown for supported hosts
      - A text input for the image URL
      - A preview of the image (smol)
      - A clear button
    At the bottom of the list panel, there will be an extra row, for stock pics
    It'll have a button you can press, and it'll open a new window with a list of stock pics
    We'll get into that later.

  Message Appearance:
    This is where you set up the Geocities-style HTML gradient stuff.
    You can set up a gradient for the background of each of the boxes,
    as well as setup border colors, styles, and widths.
    Web 2.0? Never heard of it.
    Lots of tabs, lots of options.
    there are two columns!
      - Left column:
        The message modes, arranged vertically
        This will set a local state for the right column to display the options
        for the selected message mode!
        Each message mode will have a button to copy the settings to anothr mode
      - Right column:
        The rest of the damn owl
        This will have a bunch of options for the selected message mode
        as well as a preview of the message appearance
        It will be arranged in rows:
          - Which section of the message appearance to edit
          - The options for that section
          - A preview of the message appearance

  Preview:
    A list of preview messages, one for each message mode
    Each message will have a preview of the message appearance
    as well as an example message (worning: will contain horny)

  */

const BackMsgMode2Front = {
  "say": "Say",
  "custom_say": "Custom Say",
  "whisper": "Whisper",
  "whispercrit": "Whisper",
  "ask": "Ask",
  "exclaim": "Exclaim",
  "yell": "Yell",
  "%": "Sing", // CUS COURSE ITS %
  "emote": "Emote",
  "me": "Me",
};

// dark pale violet: #5F9EA0
// dark slate gray: #2F4F4F
// darker slate gray: #1F3A3A
// dark blue: #00008B
// dark olive green: #556B2F
// dark green: #006400
// dark red: #8B0000
// dark orange: #FF8C00
// dark goldenrod: #B8860B
// dark khaki: #BDB76B
// dark orchid: #9932CC
// dark violet: #9400D3
// dark magenta: #8B008B
// dark pink: #FF1493
// dark salmon: #E9967A
// dark tomato: #D30000
// dark coral: #FF7F50
// dark sienna: #8B4513
// dark brown: #5A2E2E
// dark chocolate: #D2691E
// dark purple: #800080
// dark indigo: #4B0082

// dark cyan: #008B8B
// dark sky blue: #8CBED6
// dark light blue: #8CBED6
// dark light green: #90EE90
// dark light red: #FF6347
// dark light orange: #FFA500
// dark light goldenrod: #DAA520
// dark light khaki: #F0E68C
// dark light orchid: #9932CC
// dark light violet: #9400D3
// dark light magenta: #EE82EE
// dark light pink: #FFB6C1
// dark light salmon: #E9967A
// dark light tomato: #FF6347
// dark light coral: #F08080
// dark light sienna: #A0522D
// dark light brown: #A52A2A
// dark light chocolate: #D2691E
// dark light purple: #9370DB
// dark light indigo: #4B0082

// dark light cyan: #008B8B
// dark light sky blue: #8CBED6
// dark light light blue: #8CBED6
// dark light light green: #90EE90
// dark light light red: #FF6347
// dark light light orange: #FFA500
// Thanks to https://www.colorhexa.com/ for the colors
// (I didnt actually use that site, I just like to thank random people)

export const HornyChat = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={900}
      height={600}
      theme="ntos"
      resizable>
      <Window.Content
        style={{
          "background": "linear-gradient(180deg, #2F4F4F, #1F3A3A)",
        }}>
        <Stack fill vertical>
          <Stack.Item>
            <UpperRowTabBar />
          </Stack.Item>
          <Stack.Item grow shrink> {/* grow shrink my beloved, you have saved so many of my garbo layouts */}
            <Section fill scrollable>
              <MainWindow />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <LowerRowBar />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// UpperRowTabBar is the top row of tabs in the HornyChat window yiff yiff
// UpperRowTab legend:
// 1: Profile Pics
// 2: Message Appearance
// 3: Preview
const UpperRowTabBar = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    UpperRowTab,
    setUpperRowTab,
  ] = useLocalState(context, 'UpperRowTab', 1);

  return (
    <Stack fill>
      <Stack.Item grow={1}>
        <Button
          fluid
          icon="user"
          selected={UpperRowTab === 1}
          onClick={() => setUpperRowTab(1)}>
          Profile Pics
        </Button>
      </Stack.Item>
      <Stack.Item grow={1}>
        <Button
          fluid
          icon="paint-brush"
          selected={UpperRowTab === 2}
          onClick={() => setUpperRowTab(2)}>
          Message Appearance
        </Button>
      </Stack.Item>
      <Stack.Item grow={1}>
        <Button
          fluid
          icon="eye"
          selected={UpperRowTab === 3}
          onClick={() => setUpperRowTab(3)}>
          Preview
        </Button>
      </Stack.Item>
    </Stack>
  );
};

// MainWindow is the main window of the HornyChat window yiff yiff
// Will route to the correct tab based on the UpperRowTab state
const MainWindow = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    UpperRowTab,
    setUpperRowTab,
  ] = useLocalState(context, 'UpperRowTab', 1);

  switch (UpperRowTab) {
    case 1:
      return (
        <ProfilePicsTab /> // i will
      );
    case 2:
      return (
        <MessageAppearanceTab /> // horny you
      );
    case 3:
      return (
        <PreviewTab /> // into the dirt
      );
  }
};

// LowerRowBar is the bottom row with two buttons:
// on the right, a "Save" button
// on the left, a "Get Profile Pics" button
// and a whole lot of nothing in between
const LowerRowBar = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    UserCKEY,
    SeeOthers,
  } = data;

  return (
    <Stack fill>
      <Stack.Item shrink>
        {/* It just links to an AI furry image algovomitorihtym thing */}
        {/* Probably the one on Perchance, that one's yiffy as heck */}
        <Button
          fluid
          icon="images"
          content="Get Profile Pics"
          onClick={() => act('OpenPerchance', {
            UserCkey: UserCKEY,
          })} />
      </Stack.Item>
      <Stack.Item shrink>
        {/* A link to catbox.moe, where you can upload your own images */}
        <Button
          fluid
          icon="upload"
          content="Upload Images (to Catbox.moe)"
          onClick={() => act('OpenCatbox', {
            UserCkey: UserCKEY,
          })} />
      </Stack.Item>
      <Stack.Item shrink>
        {/* A link to gyazo, another place to upload images */}
        <Button
          fluid
          icon="upload"
          content="Upload Images (to Gyazo)"
          onClick={() => act('OpenGyazo', {
            UserCkey: UserCKEY,
          })} />
      </Stack.Item>
      <Stack.Item shrink>
        {/* A link to gyazo, another place to upload images */}
        <Button
          fluid
          icon={SeeOthers ? "eye-slash" : "eye"}
          content={
            SeeOthers
              ? "CoolChat Visible"
              : "CoolChat Hidden"
          }
          onClick={() => act('ToggleWhinyLittleBazingaMode', {
            UserCkey: UserCKEY,
          })} />
      </Stack.Item>
      <Stack.Item grow />
      <Stack.Item shrink>
        {/* The settings autosave, so all this does it make the user feel better */}
        <Button
          fluid
          icon="save"
          content="Save"
          onClick={() => act('SaveEverything', {
            UserCkey: UserCKEY,
          })} />
      </Stack.Item>
    </Stack>
  );
};

/*
  ANATOMY OF THE Clipboard:
  Clipboard is an object with a bunch of keys
  Each key is a clipboard kind, like "ProfilePics" or "MessageAppearance"
  Each key has a value that is an object
  {
    "ProfilePic": {
      "Mode": "message mode",
      "Host": "www.Host.com",
      "URL": "image.jpg",
    },
    "MessageAppearance": {
      "huge lots of stuff": "like, a lot",
    },
  }
*/

// ProfilePicsTab is the Profile Pics tab of the HornyChat window yiff yiff
// This is where you set up your profile pics, its a bit of a mouthful
const ProfilePicsTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    UserCKEY,
    UserImages = [],
    Clipboard = {
      ProfilePic: {},
    },
    ValidHosts = [
      "oh no",
    ],
  } = data;

  // ANATOMY OF UserImages:
  // UserImages is an array of objects
  // [
  //   mode: "message mode",
  //   host: "www.Host.com",
  //   URL: "image.jpg",
  // ] // easy huh? yiff yiff

  const HasValidClipboard = Clipboard.ProfilePic
    && Clipboard.ProfilePic.Mode
    && Clipboard.ProfilePic.Host
    && Clipboard.ProfilePic.URL;

  // This will give a style to each row!
  // It will start out with #2F4F4F, #1F3A3A
  // then, based on Iter, it will shift its hue by 5 degrees
  // that color will be used as the inner section of the gradient
  // the outer section will be the same color, but 50% darker
  // it will have a border that is 1px wide, and 50% darker than the outer section
  // all hexcode will be 6 characters long, plus a #. No alpha channel.
  const CellStyle = (Mode, Iter) => {
    const ColorA = `425F12`;
    const ColorB = `A2230A`;
    const ColorA_R = parseInt(ColorA.substring(0, 2), 16);
    const ColorA_G = parseInt(ColorA.substring(2, 4), 16);
    const ColorA_B = parseInt(ColorA.substring(4, 6), 16);
    const ColorB_R = parseInt(ColorB.substring(0, 2), 16);
    const ColorB_G = parseInt(ColorB.substring(2, 4), 16);
    const ColorB_B = parseInt(ColorB.substring(4, 6), 16);
    const ColorC_R = Math.floor(ColorA_R + (ColorB_R - ColorA_R) * (Iter / UserImages.length));
    const ColorC_G = Math.floor(ColorA_G + (ColorB_G - ColorA_G) * (Iter / UserImages.length));
    const ColorC_B = Math.floor(ColorA_B + (ColorB_B - ColorA_B) * (Iter / UserImages.length));
    const ColorC = `${ColorC_R.toString(16).padStart(2, '0')}${ColorC_G.toString(16).padStart(2, '0')}${ColorC_B.toString(16).padStart(2, '0')}`;
    const ColorD_R = Math.floor(ColorC_R / 2);
    const ColorD_G = Math.floor(ColorC_G / 2);
    const ColorD_B = Math.floor(ColorC_B / 2);
    const ColorD = `${ColorD_R.toString(16).padStart(2, '0')}${ColorD_G.toString(16).padStart(2, '0')}${ColorD_B.toString(16).padStart(2, '0')}`;
    const ColorGrad1_R = Math.floor(ColorC_R / 2);
    const ColorGrad1_G = Math.floor(ColorC_G / 2);
    const ColorGrad1_B = Math.floor(ColorC_B / 2);
    const ColorGrad1_RGB_to_H = (ColorGrad1_R / 255 + ColorGrad1_G / 255 + ColorGrad1_B / 255) / 3;
    const ColorGrad1_RGB_to_L = Math.max(ColorGrad1_R / 255, ColorGrad1_G / 255, ColorGrad1_B / 255);
    const ColorGrad1_RGB_to_S = ColorGrad1_RGB_to_L - Math.min(ColorGrad1_R / 255, ColorGrad1_G / 255, ColorGrad1_B / 255);
    const ColorGrad1_RGB_to_HSL = [ColorGrad1_RGB_to_H, ColorGrad1_RGB_to_S, ColorGrad1_RGB_to_L];
    const ColorGrad1_H_Shift = (A, B) => {
      return (A + Math.hypot((B + 1) + 10 ** 20)) % 360;
    };
    const ColorGrad1_H = ColorGrad1_H_Shift(ColorGrad1_RGB_to_HSL[0], (Iter + 1));
    const ColorGrad1_S = Math.max(Math.min(Math.abs(Math.tanh(Iter) * 0.5), 0.5), 0.1);
    const ColorGrad1_L = ColorGrad1_RGB_to_HSL[2];
    const ColorGrad1 = `hsl(${ColorGrad1_H}, ${ColorGrad1_S * 100}%, ${ColorGrad1_L * 100}%)`;
    const ColorGrad2_R = Math.floor(ColorC_R / 2);
    const ColorGrad2_G = Math.floor(ColorC_G / 2);
    const ColorGrad2_B = Math.floor(ColorC_B / 2);
    const ColorGrad2_RGB_to_H = (ColorGrad2_R / 255 + ColorGrad2_G / 255 + ColorGrad2_B / 255) / 3;
    const ColorGrad2_RGB_to_L = Math.max(ColorGrad2_R / 255, ColorGrad2_G / 255, ColorGrad2_B / 255);
    const ColorGrad2_RGB_to_S = ColorGrad2_RGB_to_L - Math.min(ColorGrad2_R / 255, ColorGrad2_G / 255, ColorGrad2_B / 255);
    const ColorGrad2_RGB_to_HSL = [ColorGrad2_RGB_to_H, ColorGrad2_RGB_to_S, ColorGrad2_RGB_to_L];
    const ColorGrad2_H_Shift = (A, B) => {
      return (A + (B + 1) & 0xFDED10 | (B + 1)) % 360;
    };
    const ColorGrad2_H = ColorGrad2_H_Shift(ColorGrad2_RGB_to_HSL[0], (Iter + 1));
    const ColorGrad2_S = ColorGrad2_RGB_to_HSL[1];
    const ColorGrad2_L = ColorGrad2_RGB_to_HSL[2];
    const ColorGrad2 = `hsl(${ColorGrad2_H}, ${ColorGrad2_S * 100}%, ${ColorGrad2_L * 100}%)`;
    return {
      style: {
        "background": `linear-gradient(180deg, ${ColorGrad1}, ${ColorGrad2})`,
        "border": `1px solid #${ColorD}`,
      },
    };
  };

  // style for each of the individual cells
  // centers the elements vertically
  // sets the font size to 1.5em
  // gives the text a drop shadow cus why not
  // also makes the cells shrink to fit the content
  const CellStyleCenter = {
    style: {
      "text-align": "center",
      "vertical-align": "middle",
      "font-size": "1em",
      "text-shadow": "1px 1px 1px #000000",
      "border": "1px solid #000000",
    },
  };

  // since the damn message mode column becomes huge for no reason
  // we need to calculate the longest message mode, and set the width to that
  // plus a bit of padding cus why not
  const LongestMode = UserImages.reduce((a, b) => a.Mode.length > b.Mode.length ? a : b);
  const ModeWidth = `${(LongestMode.Mode.length) * 0.80}em`;
  // same for the host column, it is *short*, too short for the hosts
  const LongestHost = ValidHosts.reduce((a, b) => a.length > b.length ? a : b);
  const HostWidth = `${(LongestHost.length) * 0.75}rem`;

  return (
    <Table>
      {/* Column names */}
      <Table.Row>
        <Table.Cell {...CellStyleCenter} />
        <Table.Cell {...CellStyleCenter}
          width={ModeWidth}>
          Message Mode
        </Table.Cell>
        <Table.Cell {...CellStyleCenter}>
          Host
        </Table.Cell>
        <Table.Cell {...CellStyleCenter}>
          Filename
        </Table.Cell>
        <Table.Cell {...CellStyleCenter}>
          Preview
        </Table.Cell>
        <Table.Cell {...CellStyleCenter} />
      </Table.Row>
      {/* Profile pics */}
      {UserImages && UserImages.length
        ? UserImages.map((PFPentry, index) => (
          <Table.Row
            key={index}
            {...CellStyle(PFPentry.Mode, index)}>
            {/* Copy */}
            <Table.Cell {...CellStyleCenter}>
              <Button
                icon="copy"
                onClick={() => act('CopyImage', {
                  UserCkey: UserCKEY,
                  Mode: PFPentry.Mode,
                  Host: PFPentry.Host,
                  URL: PFPentry.URL,
                })} />
              {/* Paste, if we have a valid clipboard entry */}
              <Button
                disabled={!HasValidClipboard}
                icon="paste"
                onClick={() => act('PasteImage', {
                  UserCkey: UserCKEY,
                  Mode: PFPentry.Mode,
                  Host: PFPentry.Host,
                  URL: PFPentry.URL,
                })} />
            </Table.Cell>
            {/* Message Mode */}
            {/* Is static text for the hardcoded message modes */}
            {/* Is a text input for custom message modes */}
            <Table.Cell {...CellStyleCenter}>
              {PFPentry.Modifiable ? (
                <Button.Input
                  content={PFPentry.Mode}
                  currentValue={PFPentry.Mode}
                  defaultValue={":cutecat:"}
                  onCommit={(e, value) => act('ModifyModename', {
                    UserCkey: UserCKEY,
                    Mode: PFPentry.Mode,
                    NewName: value,
                  })} />
              ) : (
                DisplayMessageMode(PFPentry.Mode)
              )}
            </Table.Cell>
            {/* Host, is a dropdown box */}
            <Table.Cell {...CellStyleCenter}>
              <Dropdown
                fluid
                width={HostWidth}
                options={ValidHosts}
                selected={PFPentry.Host}
                onSelected={value => act('ModifyHost', {
                  UserCkey: UserCKEY,
                  Mode: PFPentry.Mode,
                  NewHost: value,
                })} />
            </Table.Cell>
            {/* Filename, is a text input */}
            <Table.Cell {...CellStyleCenter}>
              <Input
                value={PFPentry.URL}
                onChange={(e, value) => act('ModifyURL', {
                  UserCkey: UserCKEY,
                  Mode: PFPentry.Mode,
                  NewURL: value,
                })} />
            </Table.Cell>
            {/* Preview */}
            {/* Limit to, oh, lets say 100px x 100px */}
            <Table.Cell {...CellStyleCenter}>
              <Box
                as="img"
                // so, the actual URL is split into the host and the filename
                // the host is something like "https://www.host.com"
                // and the filename is "image.jpg"
                // so we need to combine them to get the full URL
                src={`${PFPentry.Host}/${PFPentry.URL}`} // yiff yiff
                width="100px"
                height="100px"
                style={{
                  objectFit: "cover",
                }} />
            </Table.Cell>
            {/* Clear */}
            <Table.Cell {...CellStyleCenter}>
              <Button.Confirm
                icon="times"
                color="#ff0000"
                confirmContent={
                  PFPentry.Modifiable ? (
                    "Delete?"
                  ) : (
                    "Reset?"
                  // eslint-disable-next-line react/jsx-indent
                  ) // eat my a$$ eslint
                }
                onClick={() => act('ClearProfileEntry', {
                  UserCkey: UserCKEY,
                  Mode: PFPentry.Mode,
                })} />
            </Table.Cell>
          </Table.Row>
        // plus one row for a button to add a new row
        )).concat(
          <Table.Row
            key="stock">
            <Table.Cell />
            <Table.Cell>
              <Button
                icon="plus"
                content="Add Message Mode"
                onClick={() => act('AddProfileEntry', {
                  UserCkey: UserCKEY,
                })} />
            </Table.Cell>
            <Table.Cell />
            <Table.Cell />
            <Table.Cell />
            <Table.Cell />
          </Table.Row>
        ) : (
          <Table.Row>
            <Table.Cell />
            <Table.Cell />
            <Table.Cell>
              No profile pics yet! Oh no!
            </Table.Cell>
            <Table.Cell />
            <Table.Cell />
            <Table.Cell />
          </Table.Row>
        )}
    </Table>
  );
};

// MessageAppearanceTab is the Message Appearance tab of the HornyChat window yiff yiff
// This is where you set up your message appearance, its a bit of a mouthful (like your mom)
// LAYOUT!
// four main sections:
// 1: The left column, with the message modes, arranged vertically
// 2: The top of the right column, with the sections of the message appearance
// 3: The middle of the right column, with the settings for the selected section
// 4: The bottom of the right column, with a preview of the message appearance
// and it'll all be wrapped in a Stack
// NOTE: stack has problems with text stretching off the screen
// so we'll need to wrap it in a Section, which will have a max-width
// and overflow-wrap. That never helps, but we'll try it anyway
const MessageAppearanceTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    UserImages = [], // used for extracting the message modes
    TopBox = [], // We are passed all the settings for all the message modes
    BottomBox = [], // We will determine which settings to use based on SettingsModeSelected
    Buttons = [], // Then we will sort them into two columns based on Loc
    OuterBox = [], // and pass them all to SettingBlock
    ImageBox = [], // which will render them
    UserCKEY,
    Clipboard = {
      MessageAppearance: {}, // and also pass the clipboard
      ModeBatch: {},
    },
  } = data;

  const [ // Used for determining which message mode we are editing
    MsgModeTabSelected,
    setMsgModeTabSelected,
  ] = useLocalState(context, 'MsgModeTabSelected', "say");

  const [
    SettingsModeSelected,
    setSettingsModeSelected,
  ] = useLocalState(context, 'SettingsModeSelected', "Top Box");

  // extract a list of message modes from the UserImages
  const PreMessageModes = UserImages.map(PFPentry => PFPentry.Mode);
  // remove the "Profile / Examine" message mode, cus its not a real message mode
  const MessageModes = PreMessageModes.filter(Mode => Mode !== "Profile / Examine");

  // Objectify the settings as key => array of settings
  const ValidSettings = {
    "Top Box": TopBox || [],
    // "Image Box": ImageBox || [], // turns out the image box is beansed
    "Buttons": Buttons || [],
    "Bottom Box": BottomBox || [],
    "Outer Box": OuterBox || [],
  };

  // If SettingsModeSelected is not in the list of valid settings, set it to the first one
  if (!Object.keys(ValidSettings).includes(SettingsModeSelected)) {
    setSettingsModeSelected(Object.keys(ValidSettings)[0]);
  }

  // SO. the format of the arrays of settings are as follows:
  // [
  //   {
  //     Mode: 'yell',
  //     Name: 'Image Border',
  //     Settings: [ // this is the part that we send to SettingBlock
  //       {
  //         Name: 'Border Color',
  //         Val: '#222222',
  //         Type: 'COLOR',
  //         Loc: 'L',
  //         PKey: 'ImageBorderBorderColor',
  //         Desc: 'The color of the border for the images.',
  //         Default: '000000'
  //       },
  //       {
  //         Name: 'Border Width', // etc
  //       },
  //     ],
  //   },
  // } // easy huh? yiff yiff
  // So what we need is to extract the settings from the correct Settings array
  // that matches the selected message mode, and sort them into two arrays
  // based on the Loc key
  // Then we pass them to SettingBlock, which will render them
  // and all will be yiff yiff
  const SettingsToUse = ValidSettings[SettingsModeSelected] // the reason we use [] instead of . is because we need to use a variable key
    .find(Setting => Setting.Mode === MsgModeTabSelected);
  const LeftColumn = SettingsToUse
    .Settings // filter() returns an array, so we can chain map() to it
    .filter(Setting => Setting.Loc === "L");
  const RightColumn = SettingsToUse
    .Settings // filter() works by going through each element in the array, and returning a new array with only the elements that return true
    .filter(Setting => Setting.Loc === "R");

  // Check if we have a valid clipboard entry that's compatible with modes
  const HasValidModeClipboard = Clipboard.MessageAppearance
    && Clipboard.MessageAppearance.length > 0; // backend will know what do

  return (
    // Horizontal stack, with two columns
    <Stack fill>
      {/* Left column */}
      <Stack.Item>
        <Stack fill vertical> {/* Vertical stack of message mode butts */}
          {MessageModes.map((Mode, index) => (
            <Stack.Item key={index}>
              {/* Copy Paste, cus I love croppy piss */}
              <Stack fill>
                <Stack.Item>
                  <Button
                    icon="copy"
                    onClick={() => act('CopyModeSettings', {
                      UserCkey: UserCKEY,
                      Mode: Mode,
                    })} />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="paste"
                    mr="0.5em"
                    disabled={!HasValidModeClipboard}
                    onClick={() => act('PasteModeSettings', {
                      UserCkey: UserCKEY,
                      Mode: Mode,
                    })} />
                </Stack.Item>
                <Stack.Item grow>
                  {/* The actual button */}
                  <Button
                    fluid
                    selected={Mode === MsgModeTabSelected}
                    onClick={() => setMsgModeTabSelected(Mode)}>
                    {DisplayMessageMode(Mode)}
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          ))} {/* End of message mode butts */}
        </Stack>
      </Stack.Item>
      {/* Right column, the main meaty potatoe */}
      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item>
            <Stack fill>
              {/* Top Right Row of Selector Butts */}
              {Object.keys(ValidSettings).map((Setting, index) => (
                <Stack.Item key={index}>
                  <Button
                    fluid
                    selected={Setting === SettingsModeSelected}
                    onClick={() => setSettingsModeSelected(Setting)}>
                    {Setting}
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            {/* Middle Right Row of Settings */}
            <Stack fill>
              {/* Left column */}
              <Stack.Item basis="50%">
                <Stack fill vertical>
                  {LeftColumn.map((Setting, index) => (
                    <Stack.Item key={index}>
                      <SettingBlock SetBlock={Setting} />
                    </Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
              {/* Right column */}
              <Stack.Item basis="50%">
                <Stack fill vertical>
                  {RightColumn.map((Setting, index) => (
                    <Stack.Item key={index}>
                      <SettingBlock SetBlock={Setting} />
                    </Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            {/* Bottom Right Row, the Preview */}
            {/* Surprise surprise, it mangles the formatting */}
            {/* Eat a fukcing c0ck, Inferno */}
            <Section
              // title={`Preview: ${DisplayMessageMode(MsgModeTabSelected)}`}
              fitted
              overflow="auto">
              <Box
                p={1}>
                <GetPreview MMode={MsgModeTabSelected} />
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {/* And the bookend so that the stack reaches the edges */}
      <Stack.Item /> {/* Does nothing but the format cant live without it, my spirit animal */}
    </Stack>
  );
};


// SettingBlock is a single row in the settings list
// This is where you set up the message appearance for the selected message mode
const SettingBlock = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    SetBlock,
  } = props;

  const {
    NumbermalMin = 0,
    NumbermalMax = 10,
    AnglemalMin = 0,
    AnglemalMax = 360,
    Clipboard = {},
    UserCKEY,
  } = data;

  const {
    Name = "MySpace",
    Val = "Tom",
    Type = "COLOR",
    PKey = "MySpaceTom",
    Desc = "Tom shouldn't have sold MySpace",
    Default = "Tom",
    Options = [],
  } = SetBlock;

  // ANATOMY OF SetBlock:
  // {
  //   Name: 'Border Style',
  //   Val: 'solid',
  //   Type: 'SELECT',
  //   Loc: 'L',
  //   PKey: 'ImageBorderBorderStyle',
  //   Desc: 'The style of the border for the images.',
  //   Default: 'solid',
  //   Options: [
  //     'solid',  'dotted',
  //     'dashed', 'double',
  //     'groove', 'ridge',
  //     'inset',  'outset',
  //     'none',   'hidden'
  //   ]
  // }
  // Well not quite, cus of Type and Loc.
  // Type is either "COLOR", "NUMBER", or "SELECT"
  //   - COLOR will just open BYOND's (the backend's) lovely color picker
  //   - NUMBER will be a fancy number draggy thing
  //   - SELECT will be a dropdown box
  // Loc is either "L" or "R"
  //   The settings box is split into two columns, left and right
  //   Loc will determine which column the setting will be in
  //   This will be pre-sorted by us before we render it! yiff yiff

  // Check if we have a valid clipboard entry that's compatible with this setting
  // first check if the clipboard entry is in fact an object, and not, say, a string
  const HasValidClipboard = Clipboard
    && Object.keys(Clipboard).length > 0
    && Clipboard.MsgSetting
    && Clipboard.MsgSetting.Type === Type
    && (Type !== "SELECT" || Options.includes(Clipboard.MsgSetting.Val));
    // && Clipboard.MsgSetting.Val !== Val; // so we don't paste the same value

  const [ // Used for determining which message mode we are editing
    MsgModeTabSelected,
    setMsgModeTabSelected,
  ] = useLocalState(context, 'MsgModeTabSelected', "say");

  // fun fact, putting a dropdown in a switch in a function causes it to close every time the window updates
  // or something

  return (
    <Box
      inline
      width="100%"
      p={1}
      style={{
        "border": "1px solid #2F4F4F",
        "border-radius": "5%",
        "background": "linear-gradient(180deg, #2F4F4F, #1F3A3A)", // here have a gradient, as a treat
      }}>
      <Stack fill>
        <Stack.Item>
          {/* Copypaste */}
          <Button
            icon="copy"
            onClick={() => act('CopySetting', {
              UserCkey: UserCKEY,
              Mode: MsgModeTabSelected,
              PKey: PKey,
              Type: Type,
            })} />
          <Button
            disabled={!HasValidClipboard}
            icon="paste"
            onClick={() => act('PasteSetting', {
              UserCkey: UserCKEY,
              Mode: MsgModeTabSelected,
              PKey: PKey,
              Type: Type,
            })} />
        </Stack.Item>
        <Stack.Item grow={1}>
          {Name}
        </Stack.Item>
        <Stack.Item>
          {/* The setting knot itself */}
          {(() => {
            switch (Type) {
              case "COLOR":
                return (
                  <Button
                    style={{
                      "border": "1px solid #5F9EA0",
                      "font-family": "monospace",
                    }}
                    icon="tint"
                    iconColor="#5F9EA0"
                    textColor="#5F9EA0"
                    bold
                    backgroundColor={Val}
                    content={Val}
                    onClick={() => act('EditColor', {
                      UserCkey: UserCKEY,
                      Mode: MsgModeTabSelected,
                      Val: Val,
                      PKey: PKey,
                      Current: Val,
                    })} />
                );
              case "NUMBER":
              case "ANGLE":
                return (
                  <>
                    {Type === "ANGLE"
                      ? <Icon px={1} name="arrow-up" rotation={Val + 180} color="#FFFFFF" />
                      : null}
                    <NumberInput
                      animated
                      value={Val}
                      minValue={Type === "NUMBER" ? NumbermalMin : AnglemalMin}
                      maxValue={Type === "NUMBER" ? NumbermalMax : AnglemalMax}
                      step={Type === "NUMBER" ? 1 : 15}
                      stepPixelSize={15}
                      onChange={(e, value) => act('EditNumber', {
                        UserCkey: UserCKEY,
                        Mode: MsgModeTabSelected,
                        Val: value,
                        PKey: PKey,
                        Current: Val,
                      })} />
                  </>
                );
              case "SELECT":
                return (
                  <Dropdown
                    options={Options}
                    selected={Val}
                    onSelected={value => act('EditSelect', {
                      UserCkey: UserCKEY,
                      Mode: MsgModeTabSelected,
                      Val: value,
                      Current: Val,
                      PKey: PKey,
                    })} />
                );
              default:
                return (
                  <Stack.Item>
                    {Val}
                  </Stack.Item>
                );
            } // OH BUT JUST STICKING THE WHOLE DAMN THING HERE IS FINE THOUGH OKAY COOL
          })()}
        </Stack.Item>
      </Stack>
    </Box>
  );
};


// GetPreview renders the preview of the message appearance
// to render the HTML in React, we will use the marked library
// HTML is already sanitized by the backend, so we don't need to worry about that
// The way we will make sure the HTML is rendered is by using the dangerouslySetInnerHTML prop
// This is because React doesn't like rendering HTML directly, because it's a security risk
// However, doing so will make the text not linewrap, so we will need to wrap it in a div
// and set the div to have a max-width and overflow-wrap

// ANATOMY OF UserImages:
// [
//   {
//     "Mode": "say",
//     "Message": "<div>...</div>",
//   },
//   {
//     "Mode": "whisper",
//     "Message": "<div>...</div>",
//   }, // etc
// ] // easy huh? yiff yiff

const GetPreview = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    MMode = "say",
    ShowMessageMode = false,
  } = props;
  const {
    PreviewHTMLs = [],
  } = data;

  const Preview = PreviewHTMLs.find(PFPentry => PFPentry.Mode === MMode);

  return (
    <Box
      style={{
        "border": "1px solid #5F9EA0",
        "border-radius": "5%",
        "max-width": "100%",
        "overflow-wrap": "break-word",
      }}
      mx="auto"
      p={3}
      width="400px"
      minHeight="300px">
      <Stack
        fill
        vertical>
        {ShowMessageMode && (
          <Stack.Item textAlign="center" >
            <Box
              as="h2">
              {DisplayMessageMode(MMode)}
            </Box>
          </Stack.Item>
        )}
        <Stack.Item>
          <Box
            dangerouslySetInnerHTML={{ __html: Preview.Message }} />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

// converts the backend message modes to frontend message modes
// but also passes through the message modes that are not in the list
const DisplayMessageMode = (Mode) => {
  return BackMsgMode2Front[Mode] || Mode;
};

// and, the preview tab
// returns a list of all the message modes, and their previews
// and the message appearance for each message mode
const PreviewTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    UserImages = [],
  } = data;

  return (
    <Stack fill vertical>
      {UserImages.map((PFPentry, index) => (
        <Stack.Item key={index}>
          <GetPreview
            MMode={PFPentry.Mode}
            ShowMessageMode />
        </Stack.Item>
      ))}
    </Stack>
  );
};









