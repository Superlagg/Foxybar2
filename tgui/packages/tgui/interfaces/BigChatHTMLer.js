import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Flex, TextArea } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';


/*
  * Literally just a textbox that can be used to send messages to the chat.
  * Used to debug and preview complicated html stuff that'll go to chat
*/

export const BigChatHTMLer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    TextFromBYOND,
    WhoCKEY,
  } = data;

  const [TextCache, setTextCache] = useLocalState(context, 'TextCache', '');

  const TextShow = TextCache.length > 0 ? TextCache : TextFromBYOND;

  return (
    <Window
      width={800}
      height={600}>
      <Window.Content>
        <Section title="Big Chat HTMLer">
          <Flex direction="column">
            <Flex.Item grow={1}>
              <TextArea
                value={TextShow}
                height="100%"
                width="100%"
                onInput={(e, value) => setTextCache(value)} />
            </Flex.Item>
            <Flex.Item>
              <Button
                content="Send"
                onClick={() => act('SendText', {
                  Text: TextShow,
                  Who: WhoCKEY,
                })} />
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};





