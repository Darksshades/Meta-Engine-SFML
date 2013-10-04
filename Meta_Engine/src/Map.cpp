#include "Map.h"
#include "MetaEngine.h"
#include "Defines.h"
#include "Player.h"
#include "Item.h"
#include "ResourceManager.h"

#include <iostream>
#include <fstream>
#include <iostream>
#include <sstream>
using namespace std;
Map Map::MapControl;
Map::Map()
{
    //ctor

    int a = 0;
    setFlag(a, EX_SEEN);
    a = 0;

    if(isFlag(a, EX_HAS_SEEN | EX_SEEN) )
        cout << "isSEEN!\n";

    removeFlag(a, EX_SEEN);

    if(isFlag(a, EX_SEEN) )
        cout << "SEEN AGAIN\n";
    if(isFlag(a, EX_HAS_SEEN) )
        cout << "SEEN NO AGAIN\n";
}

Map::~Map()
{
    //dtor
    tileMap.clear();
}

void Map::createMap(int sizeW, int sizeH)
{
    assert(tileMap.empty());

    tileMap.clear();
    exploreMap.clear();
    tileMap.resize(sizeW);
    exploreMap.resize(sizeW);

    for(int i = 0; i < sizeW; ++i)
    {
        tileMap[i].resize(sizeH);
    }
    for(int i = 0; i < sizeW; ++i)
    {
        exploreMap[i].resize(sizeH, 0);
    }

    //std::cout << tileMap.size() << "-" << tileMap[0].size() << std::endl;
}
void Map::clearMap()
{
    for(int i = 0; i < getMapWidth(); ++i)
    {
        tileMap[i].clear();
    }
    tileMap.clear();
    exploreMap.clear();
}

bool Map::loadMap(std::string filename)
{
    clearMap();


    std::ifstream myfile;
    string absFileName("./data/map/"+filename);
    myfile.open( absFileName.c_str());//string("./data/map/"+filename).c_str() );

    if(myfile.is_open() == false){
        printf("Nao foi possivel abrir o arquivo: %s.\n", absFileName.c_str());
        return false;
    }

    int map_width = -1, map_height = -1;

    int player_x = 0;
    int player_y = 0;
    myfile >> player_x;
    myfile.ignore(3,'.');
    myfile >> player_y;

    myfile >> map_width;
    myfile.ignore(20,'-');
    myfile >> map_height;


    //Ajusta o maior tamanho do mapa
    if(map_width < 0 ) return false;
    if(map_height < 0) return false;



    createMap(map_width, map_height);

    for (int y = 0; y < map_height; y++)
    {
        for (int x = 0; x < map_width; x++)
        {   // Le Tiles e joga-os no TileList
            Tile tempTile;
            myfile >> tempTile.id; myfile.ignore(1,':');
            myfile >> tempTile.tipo;


            tileMap[x][y] = tempTile;
        }
    }//Fim preencher tileList

    Player::PlayerControl->setPosition(player_x, player_y);

    myfile.ignore(20,'\n');

    std::string str;

    int px, py, hp, mp, atk, def, range, speed,sprIdx, sprIdy, buff;
    while (myfile.eof() == false) //Le a linha
    {
        myfile >> str;
        if(strcasecmp(str.c_str(), "Enemy:") == 0)
        {
            myfile >> px; myfile.ignore(3,',');
            myfile >> py; myfile.ignore(3,',');
            myfile >> hp; myfile.ignore(3,',');
            myfile >> atk; myfile.ignore(3,',');
            myfile >> def; myfile.ignore(3,',');
            myfile >> range; myfile.ignore(3,',');
            myfile >> speed; myfile.ignore(3,',');
            myfile >> sprIdx; myfile.ignore(3,',');
            myfile >> sprIdy; myfile.ignore(3,',');

            Entity* ent = new Entity();
            ent->setPosition(px,py);
            ent->mHP = hp;
            ent->mAtk = atk;
            ent->mDef = def;
            ent->mRange = range;
            ent->mSpeedCost = speed;
            ent->changeSprite(sprIdx, sprIdy);

            ent->addToObjectList();
        }else
        if(strcasecmp(str.c_str(), "Gold:") == 0)
        {
            myfile >> px; myfile.ignore(3,',');
            myfile >> py; myfile.ignore(3,',');
            myfile >> hp; myfile.ignore(3,',');

            ResourceManager::ResourceControl.addGold(px,py,hp);
        } else
        if(strcasecmp(str.c_str(), "Item:") == 0)
        {
            myfile >> px; myfile.ignore(3,',');
            myfile >> py; myfile.ignore(3,',');
            myfile >> buff; myfile.ignore(3,',');
            myfile >> hp; myfile.ignore(3,',');
            myfile >> mp; myfile.ignore(3,',');
            myfile >> atk; myfile.ignore(3,',');
            myfile >> def; myfile.ignore(3,',');
            myfile >> sprIdx; myfile.ignore(3,',');
            myfile >> sprIdy; myfile.ignore(3,',');

            Item* item = new Item();
            item->setPosition(px,py);
            item->mIsBuff = buff;
            item->mHp = hp;
            item->mMp = mp;
            item->mAtk = atk;
            item->mDef = def;
            item->changeSprite(sprIdx, sprIdy);
            item->addToObjectList();
        }
    }// Fim do arquivo

    myfile.close();
    return true;
}

void Map::saveMap()
{
    ofstream file;
    file.open ("./data/map/output_map.map",ios::out | ios::binary);

    int map_width = getMapWidth();
    int map_height = getMapHeight();
    int player_x = Player::PlayerControl->getPositionX();
    int player_y = Player::PlayerControl->getPositionY();
    file << player_x << "." << player_y << "\n";
    file << map_width << "-" << map_height << "\n";

    for (int y = 0; y < map_height; y++)
    {
        for (int x = 0; x < map_width; x++)
        {

            file << tileMap[x][y].id << ":" << tileMap[x][y].tipo;
            file << " ";
        }
        file << "\n";
    }
    file << "\n";

    //Salva inimigos e itens

    for(unsigned int i = 0; i < ObjectList.size(); ++i)
    {
        if(ObjectList[i]->type == TYPE_ENEMY)
        {
            file << "Enemy:\n";
            Entity* ent = (Entity*)ObjectList[i];
            file << ent->getPositionX() << ',' << ent->getPositionY() << ','
                    << ent->mHP << ',' << ent->mAtk << ',' << ent->mDef << ','
                    << ent->mRange << ',' << ent->mSpeedCost << ','
                    << ent->getSpriteIdx() << ',' << ent->getSpriteIdy() << '\n';

        }
        else
        if(ObjectList[i]->type == TYPE_ITEM)
        {
            Item* item = (Item*)ObjectList[i];
            if(item->mGold != 0)
            {
                file << "Gold:\n";
                file << item->getPositionX() << ',' << item->getPositionY() << ','
                        << item->mGold << '\n';
            }
            else
            {
                file << "Item:\n";
                file << item->getPositionX() << ',' << item->getPositionY() << ','
                        << item->mIsBuff << ',' << item->mHp << ','
                        << item->mMp << ',' << item->mAtk << ',' << item->mDef << ','
                        << item->getSpriteIdx() << ',' << item->getSpriteIdy() << '\n';
            }
        } //Fim item
    } //Fim for

    file.close();

}


//-------- Draw Map ----------
void Map::draw()
{
    for(unsigned int i = 0; i < tileMap.size(); ++i)
    {
        for(unsigned int j = 0; j < tileMap[i].size();++j)
        {
            if(MetaEngine::EngineControl.isMapFog() &&
                   !has_seens(i,j)) continue;

            Tile& tile = tileMap[i][j];

            if(mSprite.getTexture() == nullptr)
            {
                //Se player não ve, no renderiza.
                if(tile.tipo == 0) {
                    MetaEngine::EngineControl.drawRectVertex(i*TILE_SIZE,j*TILE_SIZE,
                                               TILE_SIZE,TILE_SIZE,
                                               sf::Color::Black);
                } else if(tile.tipo == 1){
                    MetaEngine::EngineControl.drawRectVertex(i*TILE_SIZE,j*TILE_SIZE,
                                               TILE_SIZE,TILE_SIZE,sf::Color::White);
                } else if(tile.tipo == 2){
                    MetaEngine::EngineControl.drawRectVertex(i*TILE_SIZE,j*TILE_SIZE,
                                               TILE_SIZE,TILE_SIZE,sf::Color::Yellow);
                }else if(tile.tipo == 3){
                    MetaEngine::EngineControl.drawRectVertex(i*TILE_SIZE,j*TILE_SIZE,
                                               TILE_SIZE,TILE_SIZE,sf::Color::Blue);
                }
                else if(tile.tipo == 4){
                    MetaEngine::EngineControl.drawRectVertex(i*TILE_SIZE,j*TILE_SIZE,
                                               TILE_SIZE,TILE_SIZE,sf::Color::Magenta);
                }
            } // Fim sem sprite
            else
            {
                int tileImg = tile.tipo;
                if(tileImg == 0) continue;
                mSprite.setPosition(i*TILE_SIZE, j*TILE_SIZE);
                mSprite.setTextureRect(sf::IntRect(tileImg*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE));
                MetaEngine::EngineControl.getWindowReference().draw(mSprite);
            }
        } // fim for
    } //fim for
}


void Map::setTile(int x, int y, int tileID, int tileColor)
{
    if(tileMap.empty())
    {
        std::cout << "Map not created\n";
    }
    if(x >= (int) tileMap.size() || y >= (int) tileMap[0].size() || x < 0 || y < 0)
    {
        //std::cout << "Out of boundaries: " << x << "," << y << " max: " << (tileMap.size()-1) << "," <<
          //  (tileMap[0].size()-1) << std::endl;
        return;
    }
    if(tileID >=0){
        tileMap[x][y].id = tileID;
    }
    tileMap[x][y].tipo = tileColor;
}

Tile* Map::getTile(int x, int y)
{
    if(x < 0 || y < 0 || x >= (int)tileMap.size() || y >= (int)tileMap[0].size()){
        return nullptr;
    }
    return &tileMap[x][y];
}


int Map::getMapWidth()
{
    return tileMap.size();
}

int Map::getMapHeight()
{

    return tileMap[0].size();
}

void Map::setSprite(sf::Texture& texture)
{
    mSprite.setTexture(texture);
}

GameObject* Map::getObj(int x, int y, int index)
{
    if (x < 0 || y < 0) return nullptr;
    if (x >= getMapWidth() || y >= getMapHeight() ) return nullptr;

    if(tileMap[x][y].obj.empty() || index >= (int)tileMap[x][y].obj.size() || index < 0) return nullptr;

    return tileMap[x][y].obj[index];
}

GameObject* Map::getIfObj(int x, int y, int typeObj)
{
    if (x < 0 || y < 0) return nullptr;
    if (x >= getMapWidth() || y >= getMapHeight() ) return nullptr;

    for(unsigned int i = 0; i < tileMap[x][y].obj.size(); ++i)
    {
        if(tileMap[x][y].obj[i]->type == typeObj){
            return tileMap[x][y].obj[i];
        }
    }
    return nullptr;
}


bool Map::isFlag(int& flags, int f){
    return ((flags & f) == f);
}
void Map::setFlag(int& flags, int f){
    flags |= f;
}
void Map::removeFlag(int& flags, int f){
    flags = flags & ~f;
}




//Lua maps
bool Map::has_seens(int x, int y)
{
    if(x < 0 || x > (int)tileMap.size()) return false;
    if(y < 0 || y > (int)tileMap[0].size()) return false;

    return isFlag(exploreMap[x][y], EX_SEEN);
}

bool Map::has_remembers(int x, int y)
{
    if(x < 0 || x > (int)tileMap.size()) return false;
    if(y < 0 || y > (int)tileMap[0].size()) return false;

    return (isFlag(exploreMap[x][y], EX_HAS_SEEN) );
}

bool Map::has_passed(int x, int y)
{
    if(x < 0 || x > (int)tileMap.size()) return false;
    if(y < 0 || y > (int)tileMap[0].size()) return false;

    return isFlag(exploreMap[x][y], EX_PASSED) ;
}


void Map::setSeen(int x, int y)
{
    if(x < 0 || x > (int)tileMap.size()) return;
    if(y < 0 || y > (int)tileMap[0].size()) return;

    setFlag(exploreMap[x][y], EX_SEEN);
}

void Map::setRemember(int x, int y)
{
    if(x < 0 || x > (int)tileMap.size()) return;
    if(y < 0 || y > (int)tileMap[0].size()) return;

    setFlag(exploreMap[x][y], EX_HAS_SEEN);
}

void Map::setPassed(int x, int y)
{
    if(x < 0 || x > (int)tileMap.size()) return;
    if(y < 0 || y > (int)tileMap[0].size()) return;

    setFlag(exploreMap[x][y], EX_PASSED);
}

void Map::setVisible(int x, int y)
{
    if(x < 0 || x > (int)tileMap.size()) return;
    if(y < 0 || y > (int)tileMap[0].size()) return;

    setFlag(exploreMap[x][y], EX_FOV);
}

void Map::setNotVisible(int x, int y)
{
    if(x < 0 || x > (int)tileMap.size()) return;
    if(y < 0 || y > (int)tileMap[0].size()) return;

    removeFlag(exploreMap[x][y], EX_FOV);
}

void Map::forceRemoveMapFlag(int x, int y, int flag)
{
    removeFlag(exploreMap[x][y],flag);
}


void Map::mapseen()
{

}

void Map::mapfov()
{

}

void Map::forceShowMap()
{
    MetaEngine::EngineControl.setMapFog(false);
    MetaEngine::EngineControl.getWindowReference().clear();
    sf::View& view = MetaEngine::EngineControl.getViewGame();
    view.setCenter(Player::PlayerControl->getPosition().x*TILE_SIZE-TILE_SIZE/4, Player::PlayerControl->getPosition().y*TILE_SIZE-TILE_SIZE/4);
    MetaEngine::EngineControl.getWindowReference().setView(view);

    draw();
    Player::PlayerControl->draw();
    for(unsigned int i = 0; i < ObjectList.size();++i)
    {
        ObjectList[i]->draw();
    }
    Player::PlayerControl->draw();

    MetaEngine::EngineControl.getWindowReference().display();
}


