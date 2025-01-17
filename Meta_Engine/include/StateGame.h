#pragma once

#include "State.h"
class StateGame : public State
{
    public:
        StateGame(sf::RenderWindow& wnd);
        virtual ~StateGame();
        void load(int stack = 0);
        int unload();
        eStateType update(float dt);
        void events(sf::Event& event);
        void render();
    protected:
        void createNewMap();
    private:
};
