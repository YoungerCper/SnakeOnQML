import QtQuick 2.12
import QtQuick.Window 2.12
import QtQml 2.12

Window{
    id: app

    width: 600
    height: 650
    visible: true
    title: qsTr("Snake")

    Rectangle{
         width: 600
         height: 50

         color: "#CCCCCC"
         x:0
         y:600


         //счётчик очков
         Text{
             id: scoreCounter

             x:0
             y:0

             font.pixelSize:40

             text: "Количество очков: " + 0

             property int score: 0

             function _ChangeScoreCount()
             {
                 score++
                 scoreCounter.text = "Количество очков: " + score
             }
         }
    }


    //игровое поле
    Rectangle{
        id: gameField
        width: 600
        height: 600
        x: 0
        y: 0

        focus: true

        property int titleSize: 10
        property bool isLive: true

        //обработчик нажатий клавиш клавиатуры
        Keys.onReleased: {

            if(event.key === Qt.Key_Up)
            {
                if(snakeHead.vectorHead != "down")
                {
                    snakeHead.vectorHead = "up"
                }
                console.log("Key Up was pressed")
            }

            if(event.key === Qt.Key_Right)
            {
                if(snakeHead.vectorHead != "left")
                {
                    snakeHead.vectorHead = "right"
                }
                console.log("Key Right was pressed")
            }

            if(event.key === Qt.Key_Down)
            {
                if(snakeHead.vectorHead != "up")
                {
                    snakeHead.vectorHead = "down"
                }
                console.log("Key Down was pressed")
            }

            if(event.key === Qt.Key_Left)
            {
                if(snakeHead.vectorHead != "right")
                {
                    snakeHead.vectorHead = "left"
                }
                console.log("Key Left was pressed")
            }

            if(event.key === Qt.Key_Escape)
            {
                console.log("Key Esc was pressed")
                app.close()
            }

            if(event.key === Qt.Key_Space)
            {
                if(gameField.isLive)
                {
                    console.log("Key Space was pressed")
                    timer.running = !timer.running
                }
            }
        }

        //голова змейки в ней определяется напрвление движения змеи,
        //при прохождении гарницы экрана она  оказывается на противоположном его крае
        Rectangle{

            id: snakeHead
            width: gameField.titleSize
            height: gameField.titleSize

            x: 3 * gameField.titleSize
            y: 0 * gameField.titleSize

            color: "#AA0000"

            property var vectorHead: "right"

            function _UpdateFunc()
            {
                snakeBody._MoveSnakeBody(_CheckFunc())
                _MoveFunc()
                if(!_IsLive())
                {
                    timer.running = false
                    gameField.isLive = false
                }
            }

            function _IsLive()
            {
                for(let i = 0; i < snakeBody.length; i++)
                {
                    if(snakeHead.x === snakeBody.get(i).x && snakeHead.y === snakeBody.get(i).y)
                    {
                        return false
                    }
                }

                return true
            }

            function _CheckFunc()
            {
                if(apple.x === snakeHead.x && apple.y === snakeHead.y)
                {
                    scoreCounter._ChangeScoreCount()
                    apple._SpawnNew()
                    return true
                }
                return false
            }

            function _MoveFunc()
            {
                switch(vectorHead)
                {
                case "right":
                    x += gameField.titleSize
                    break
                case "left":
                    x -= gameField.titleSize
                    break
                case "up":
                    y -= gameField.titleSize
                    break
                case "down":
                    y += gameField.titleSize
                    break
                }
                x = (x + gameField.width) % gameField.width
                y = (y + gameField.height) % gameField.height
            }

        }


        //тело змейки
        ListModel{
            id: snakeBody

            property int length: 2

            function _MoveSnakeBody(appendNew)
            {
                let memoryComponent = { x:snakeHead.x, y: snakeHead.y}
                for(let i = 0; i < length; i++)
                {
                    let t = {x:0, y:0}
                    t.x = memoryComponent.x
                    t.y = memoryComponent.y
                    memoryComponent.x = get(i).x
                    memoryComponent.y = get(i).y
                    get(i).x = t.x
                    get(i).y = t.y
                }

                if(appendNew)
                {
                    _AppendNewComponent(memoryComponent)
                }
            }

            function _AppendNewComponent(newComponent)
            {
                append({    x: newComponent.x,
                            y: newComponent.y})
                length++
            }

            Component.onCompleted: {
                append({    x: (snakeHead.x - gameField.titleSize + gameField.width) % gameField.width,
                            y: snakeHead.y})
                append({    x: (snakeHead.x - 2 * gameField.titleSize + gameField.width) % gameField.width,
                            y: snakeHead.y})
            }
        }

        ListView{
            id: snakeView
            model: snakeBody
            width: parent
            height: parent

            x:0
            y: 0

            delegate: Rectangle{
                width: gameField.titleSize
                height: gameField.titleSize

                x: 0
                y: 0

                Repeater{
                    model: snakeBody

                    Rectangle{
                                    width: gameField.titleSize
                                    height: gameField.titleSize
                                    color: "#FF0000"

                                    x: model.x
                                    y: model.y
                    }
                }

            }
        }

        //фигура яблока
        Rectangle{
            id: apple

            x: 0 * gameField.titleSize
            y: 0 * gameField.titleSize

            width: gameField.titleSize
            height: gameField.titleSize

            color: "#0000FF"

            function _SpawnNew()
            {
                x = Math.floor(Math.random() * gameField.width / gameField.titleSize) * gameField.titleSize
                y = Math.floor(Math.random() * gameField.height / gameField.titleSize) * gameField.titleSize
            }
        }



        //таймер ( и всё это просто таймер, ничего большего )
        Timer{
            id: timer
            interval: 100
            running: true
            repeat: true

            onTriggered: snakeHead._UpdateFunc()
        }


    }
}

