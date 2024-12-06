/* eslint-disable react/no-danger */
// 80 characters is not big enough for my yiff yiff
/* eslint-disable max-len */
import { createSearch, decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Divider,
  Flex,
  Fragment,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

// Welcome to the FoodPrinter.js file. This is where your food printing adventure begins.
// Layout will have four main sections:
// 0. HEADER: The top section with the title and a button for helpmepls
// 1. WORKLIST: The top section with the work list of things being printed
// 2. MENUPANE: The left section with the menu of items to print
// 3. INFO: The upper right section with the info about the selected item
// 4. OUTPUT: The lower right section with selections for output
// 5. FOOTER: The bottom section with the print button and other options

// Constants
const WorkOrderHeight = 100;
const WorkOrderWidth = 100;

// The skeleton of the FoodPrinter!
export const FoodPrinter = (props, context) => {
  const { data } = useBackend(context);

  return (
    <Window
      width={800}
      height={600}>
      <Window.Content
        style={{
          "background": "linear-gradient(180deg, #2F4F4F, #1F3A3A)",
        }}>
        <Stack fill vertical>
          <Stack.Item>
            <TopSection />
          </Stack.Item>
          <Stack.Item grow>
            <BodySection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// The top section of the FoodPrinter
// Contains the header and worklist
const TopSection = (props, context) => {
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Header />
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          title="Worklist">
          <Worklist />
        </Section>
      </Stack.Item>
    </Stack>
  );
};

// The header of the FoodPrinter
const Header = (props, context) => {
  const { data } = useBackend(context);
  const {
    NameThisRound,
    TaglineThisRound,
  } = data;
  return (
    <Stack fill>
      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item>
            <Box
              bold
              fontSize="16px">
              {NameThisRound}
              <br />
              <Divider />
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Box
              fontSize="8px">
              {TaglineThisRound}
            </Box>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="question"
          content="Help"
          onClick={() => setHelpActive(!HelpActive)} />
      </Stack.Item>
    </Stack>
  );
};

// The Worklist of the FoodPrinter
// A horizontal list of items being printed, from left to right
// Will have a scroll bar if there are too many items
const Worklist = (props, context) => {
  const { data } = useBackend(context);
  const {
    Worklist,
  } = data;

  if (!Worklist || Worklist.length === 0) {
    return (
      <NoticeBox
        height={WorkOrderHeight}
        width={WorkOrderWidth}>
        Standing by for orders! =3
      </NoticeBox>
    );
  }

  return (
    <Flex
      wrap="no-wrap"
      height={WorkOrderHeight}
      width="100%">
      {Worklist.map((item, index) => (
        <Flex.Item
          key={index}
          basis={WorkOrderWidth}>
          <WorkOrder
            item={item} />
        </Flex.Item>
      ))}
    </Flex>
  );
};

// The individual work order in the Worklist
// Contains the name of the item being printed, a progress bar, and a cancel button
// Also who its for!
const WorkOrder = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    item,
  } = props;
  const {
    Name,
    Description,
    Amount,
    OutputTag,
    TimeLeft,
    TimeLeftPercent,
    MyTag,
  } = item;

  return (
    <Box
      height={WorkOrderHeight}
      width={WorkOrderWidth}>
      <Stack fill>
        <Stack.Item>
          <Stack fill vertical>
            <Stack.Item>
              <Box
                fontSize="6px">
                {`${Amount}x ${Name}`}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Box
                fontSize="4px">
                Dest: {OutputTag}
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <ProgressBar
                value={TimeLeftPercent}
                minValue={0}
                maxValue={100}
                height="10px" >
                {TimeLeft}
              </ProgressBar>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="times"
            content="Cancel"
            onClick={() => {
              act('cancel', {
                'WhichOrder': MyTag,
              });
            }} />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

// The body section of the FoodPrinter
// Contains the menu pane, info pane, and output pane
// OR is the help menu if the help button is clicked
const BodySection = (props, context) => {
  const { data } = useBackend(context);
  const [
    HelpActive,
    setHelpActive,
  ] = useLocalState(context, 'HelpActive', false);

  if (HelpActive) {
    return (
      <Box>
        <HelpSection />
      </Box>
    );
  }

  // GROSS GRIDPANE
  return (
    <Stack fill>
      <Stack.Item basis="49%">
        <Stack fill vertical>
          <Stack.Item shrink>
            <MenuHeader />
          </Stack.Item>
          <Stack.Item grow shrink>
            <Section fill scrollable>
              <MenuPane />
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item basis="49%">
        <Stack fill vertical>
          <Stack.Item basis="49%">
            <InfoPane />
          </Stack.Item>
          <Stack.Item grow>
            <OutputPane />
          </Stack.Item>
          <Stack.Item>
            <FooterButt />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

// The Menu header of the FoodPrinter menu pane
// Has Food Manu in big letters, and search bar
const MenuHeader = (props, context) => {
  const { data, act } = useBackend(context);
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');

  return (
    <Section
      fill
      title="Food!">
      <Input
        icon="search"
        placeholder="Search"
        value={searchText}
        onInput={(e, value) => setSearchText(value)} />
    </Section>
  );
};

// The Menu pane of the FoodPrinter
// Another list holder! Also perfroms search flitering
const MenuPane = (props, context) => {
  const { data } = useBackend(context);
  const {
    Menu = [], // warning, its pretty big~
  } = data;

  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');

  // Name
  // Description
  // Categories
  // NutritionalFacts
  // PrintTime
  // FoodKey

  const testSearch = createSearch(searchText, item => {
    return item.Name + item.Description;
  });
  const SearchResults = searchText.length > 0
    && Menu
      .filter(testSearch)
      .filter((item, i) => i < 100)
    || Menu;

  return (
    <Stack fill>
      {SearchResults.map((item, index) => (
        <Stack.Item
          key={index}>
          <MenuItem
            item={item} />
        </Stack.Item>
      ))}
    </Stack>
  );
};

// The individual menu item in the MenuPane
// Just a button! It sets the
const MenuItem = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    item,
  } = props;
  const {
    Name,
    Description,
    Categories,
    NutritionalFacts,
    PrintTime,
    FoodKey,
  } = item;
  const [
    selectedItem,
    setSelectedItem,
  ] = useLocalState(context, 'selectedItem', '');

  return (
    <Button
      width="100%"
      content={Name}
      selected={selectedItem === FoodKey}
      onClick={
        selectedItem === FoodKey
          ? () => setSelectedItem(null)
          : () => setSelectedItem(FoodKey)
      } />
  );
};

// The Info pane of the FoodPrinter
// Contains the info about the selected item
const InfoPane = (props, context) => {
  const { data } = useBackend(context);
  const {
    selectedItem,
  } = data;

  if (!selectedItem) {
    return (
      <NoticeBox>
        No item selected!
      </NoticeBox>
    );
  }

  const {
    Name,
    Description,
    NutritionalFacts,
    PrintTime,
  } = selectedItem;

  // nutfacts has a format of:
  // {
  //   "Calories": 100,
  //   "Sugar": 10,
  //   "Protein": 10,
  //   "Some Kind of Reagent": 10,
  //   "Some Other Kind of Reagent": 10,
  // }
  // the first three are always present, the rest are optional
  const NutThree = {
    "Calories": NutritionalFacts["Calories"],
    "Sugar": NutritionalFacts["Sugar"],
    "Protein": NutritionalFacts["Protein"],
  };
  const NutRest = Object.keys(NutritionalFacts)
    .filter(key => !Object.keys(NutThree).includes(key))
    .map(key => ({
      [key]: NutritionalFacts[key],
    }));


  return (
    <Section
      fill
      title={Name}
      buttons={(
        <NoticeBox
          width="50px">
          <Icon
            name="hourglass-half" />
          {PrintTime}s
        </NoticeBox>
      )}>
      <Stack fill vertical>
        <Stack.Item>
          <Box>
            {Description}
          </Box>
          <Divider />
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
            {Object.entries(NutThree).map(([key, value]) => (
              <LabeledList.Item
                key={key}
                label={key}>
                {value}
              </LabeledList.Item>
            ))}
            <LabeledList.Divider />
            {NutRest.map((item, index) => (
              <LabeledList.Item
                key={index}
                label={Object.keys(item)[0]}>
                {Object.values(item)[0]} units
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

// The Output pane of the FoodPrinter
// Contains where you can make the item go to
// beacon format: "What We See": "What We Send"
const OutputPane = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    Beacons = { "Right Here": "NONE" },
  } = data;

  const [
    selectedBeacon,
    setSelectedBeacon,
  ] = useLocalState(context, 'selectedBeacon', '');

  const SendHere = selectedBeacon === '';

  return (
    <Section
      fill
      title="Output where?"
      buttons={(
        <Button.Checkbox
          checked={SendHere}
          content="Just here"
          onClick={() => setSelectedBeacon('')} />
      )}>
      <Stack fill vertical>
        {Object.entries(Beacons).map(([key, value]) => (
          <Stack.Item
            key={key}>
            <Button.Checkbox
              width="100%"
              content={key}
              checked={selectedBeacon === value}
              onClick={
                selectedBeacon === value
                  ? () => setSelectedBeacon('')
                  : () => setSelectedBeacon(value)
              } />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

// The Footer of the FoodPrinter
// Contains the print button and other options
const FooterButt = (props, context) => {
  const { data, act } = useBackend(context);
  const [
    selectedItem,
    setSelectedItem,
  ] = useLocalState(context, 'selectedItem', '');
  const [
    selectedBeacon,
    setSelectedBeacon,
  ] = useLocalState(context, 'selectedBeacon', '');

  if (!selectedItem) {
    return (
      <NoticeBox>
        No item selected!
      </NoticeBox>
    );
  }

  return (
    <Stack fill>
      <Stack.Item grow>
        Print!
      </Stack.Item>
      <Stack.Item>
        <Button
          content="1"
          onClick={() => act('PrintFood', {
            'FoodKey': selectedItem,
            'OutputTag': selectedBeacon,
            'Amount': 1,
          })} />
      </Stack.Item>
      <Stack.Item>
        <Button
          content="5"
          onClick={() => act('PrintFood', {
            'FoodKey': selectedItem,
            'OutputTag': selectedBeacon,
            'Amount': 5,
          })} />
      </Stack.Item>
      <Stack.Item>
        <Button.Input
          content={"More?"}
          maxValue={30}
          onCommit={(e, value) => act('PrintFood', {
            'FoodKey': selectedItem,
            'OutputTag': selectedBeacon,
            'Amount': value,
          })} />
      </Stack.Item>
    </Stack>
  );
};

// The Help section of the FoodPrinter
// Contains the help menu
const HelpSection = (props, context) => {
  return (
    <Section
      fill
      title="Help!">
      <Stack fill vertical>
        <Stack.Item>
          <Box>
            <b>How to use the Food Printer:</b>
            <br />
            1. Select an item from the menu on the left.
            <br />
            2. Select where you want the item to go on the right.
            <br />
            3. Select how many of the item you want to print.
            <br />
            4. Click the print button.
            <br />
            5. Wait for your item to be printed!
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};






