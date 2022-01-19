// fix the word searching set up (as if when a letter as multiple of the same neighbours)

import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.awt.Toolkit;
import java.awt.image.BufferedImage;
import java.awt.Color;
import java.awt.event.InputEvent;

int boardSize = 8;

float tileSize = 56.5;
int letterBuffer = 13;

int levelCheckX = 420;
int levelCheckY = 420;

int isx = 235; // start x
int isy = 41; // start y

float sx = isx;
float sy = isy;

float ex; // end x
float ey; // end y

int res = 16; //tileSize - letterBuffer * 2;
boolean[][] letterMap = new boolean[res][res];

boolean red = false;

ArrayList<TypedLetter> typedLetters = new ArrayList<TypedLetter>();

BufferedImage screen = null;
Robot robot;

ArrayList<PVector> bitsChecked = new ArrayList<PVector>(); 
ArrayList<PVector> currentDot = new ArrayList<PVector>(); 
int dotThreshold = 10;



boolean PCVersion = true;

HashMap<String, Integer> pointTable = new HashMap<String, Integer>();

int size = PCVersion ? 8 : 7;
Letter[][] letters = new Letter[size][size];

int letterSize;

Tree tree = new Tree();
ArrayList<Node> allNodes = new ArrayList<Node>();

String[] words;

ArrayList<Letter> forced = new ArrayList<Letter>();
ArrayList<Letter> forcedOut = new ArrayList<Letter>();

String bestWord = "";
int pointsOfBestWord = 0;
ArrayList<Letter> investigating = new ArrayList<Letter>();
ArrayList<Letter> bestLetters = new ArrayList<Letter>();

String longestWord = "";
ArrayList<Letter> longestLetters = new ArrayList<Letter>();

int xkp = 0; // x keyboard position
int ykp = 0; // y keyboard position

int animation = 0;
int animationSpeed = 10; // lower is faster

String bonusWord = "";

int word = 0;

boolean draw = false;

String previousWord = "";

void setup() {
  pointTable.put("A", 1);
  pointTable.put("B", 2);
  pointTable.put("C", 2);
  pointTable.put("D", 2);
  pointTable.put("E", 1);
  pointTable.put("F", 3);
  pointTable.put("G", 2);
  pointTable.put("H", 3);
  pointTable.put("I", 1);
  pointTable.put("J", 4);
  pointTable.put("K", 3);
  pointTable.put("L", 2);
  pointTable.put("M", 2);
  pointTable.put("N", 2);
  pointTable.put("O", 1);
  pointTable.put("P", 2);
  pointTable.put("Qu",4);
  pointTable.put("R", 2);
  pointTable.put("S", 1);
  pointTable.put("T", 2);
  pointTable.put("U", 2);
  pointTable.put("V", 3);
  pointTable.put("W", 3);
  pointTable.put("X", 4);
  pointTable.put("Y", 3);
  pointTable.put("Z", 4);
  
  words = loadStrings("words1.txt");
  //if(PCVersion) words = loadStrings("C:/Users/morga/OneDrive/ONEDRIVE Archive 2019 Sep 14/Documents/TimesTable/BookWorm/words1.txt");
  //else words = loadStrings("C:/Users/morga/OneDrive/ONEDRIVE Archive 2019 Sep 14/Documents/TimesTable/BookWorm/words2.txt");
  
  tree.fillTree();
  
  //for(Node node : allNodes) {
  //  if(node.endNode()) {
  //    println(node.toString());
  //  }
  //}
  
  setBlankBoard();
  
  size(800, 600);
  letterSize = height / (size + 1 - (PCVersion ? 1 : 0));
  
  try {
    robot = new Robot();
  }
  catch (AWTException e) {
    print("error");
  }
  
  ex = sx + tileSize;
  ey = sy + tileSize;
  
  sx += letterBuffer;
  sy += letterBuffer;
  ex -= letterBuffer;
  ey -= letterBuffer;
  
  fillTypedLetters();
  delay(10000); // 10 seconds
}

void setBlankBoard() {
  for(int x = 0; x < size; x++) {
    for(int y = 0; y < size; y++) {
      letters[x][y] = new Letter("", x, y, RewardTier.NOTHING, false);//(randomLetter(), x, y); 
      //letters[x][y] = new Letter(randomLetter(), x, y, 0); 
    }    
  }  
}

void draw() {
  while(blankOnBoard()) {
    nextLetter();  
  }
  enterBestWord();

  //String oldLetter = bestLetters.get(0).letter;

  //xkp = bestLetters.get(0).x;
  //ykp = bestLetters.get(0).y;
  
  //updateScreen();
  //findLetter();
  //matchLetter();
  
  //if(oldLetter.equals(letters[xkp][ykp].letter)) {
  //  setBlankBoard();  
  //}
  
  if(!draw) return;
  
  for(int x = 0; x < size - (PCVersion ? 1 : 0); x++) {
    for(int y = 0; y < size; y++) {
      if(!PCVersion || y != size - 1 || (x % 2 == 1)) {
        int offset = (x % 2 == (PCVersion ? 1 : 0)) ? 0 : letterSize / 2;
        
        boolean coloured = false;
        
        switch(letters[x][y].tier) {
          case NOTHING:
            fill(200, 200, 150);
          break;
          case GREEN:
            fill(0, 255, 0);
            coloured = true;
          break;
          case GOLD:
            fill(255, 223, 0);
            coloured = true;
          break;
          case SAPPHIRE:
            //fill(190);
            fill(112, 209, 244);
            coloured = true;
          break;
          case DIAMOND:
            //fill(112, 209, 244);
            fill(190);
            coloured = true;
          break;
        }
        
        if(forcedOut.contains(letters[x][y])) {
          fill(0, 0, 0);  
          coloured = true;
        }
        
        if(forced.contains(letters[x][y])) {
          fill(255, 150, 0);  
          coloured = true;
        }
        
        if(x == xkp && y == ykp) {
          if(!coloured) fill(0, 100, 0);
        }
        else {
          if(longestLetters.contains(letters[x][y])) {
          fill(255, 0, 255);
          if(longestLetters.indexOf(letters[x][y]) == 0) fill(200, 0, 255); 
          if(longestLetters.indexOf(letters[x][y]) == floor((float) animation / animationSpeed) % longestLetters.size()) {
            fill(200, 0, 200); 
            if(longestLetters.indexOf(letters[x][y]) == 0) fill(150, 0, 200); 
          }
        }
        if(bestLetters.contains(letters[x][y])) {
          fill(255, 255, 0);
            if(bestLetters.indexOf(letters[x][y]) == 0) fill(200, 255, 0); 
            if(bestLetters.indexOf(letters[x][y]) == floor((float) animation / animationSpeed) % bestLetters.size()) {
              fill(200, 200, 0); 
              if(bestLetters.indexOf(letters[x][y]) == 0) fill(150, 200, 0); 
            }
          }  
        }
        
        if(letters[x][y].burning) {
          fill(255, 0, 0);   
        }
        
        rect(x * letterSize, y * letterSize + offset, letterSize, letterSize);
        
        fill(0);
        if(forcedOut.contains(letters[x][y])) fill(255);
        if(bestLetters.contains(letters[x][y])) fill(100);
        textSize(letterSize);
        if(letters[x][y].getLetter().equals("Qu")) {
          textSize(letterSize * 0.8);
          text("Qu", x * letterSize, (y + 0.75) * letterSize + offset);
        }
        else text(letters[x][y].getLetter(), (x + 0.2) * letterSize, (y + 0.75) * letterSize + offset);
      }
    }
  }
  
  animation++;
  
  if(animation > animationSpeed * bestLetters.size() * longestLetters.size()) {
    animation = 0;
  }
}

void checkForLevel() {
  Color pixel = new Color(screen.getRGB(levelCheckX, levelCheckY));
  if(pixel.getRed() > 190 && pixel.getGreen() < 15 && pixel.getBlue() < 15) {
    robot.mouseMove(levelCheckX, levelCheckY);
    delay(150);
    robot.mousePress(InputEvent.BUTTON1_DOWN_MASK);
    delay(150);
    robot.mouseRelease(InputEvent.BUTTON1_DOWN_MASK);
    setBlankBoard();
    updateScreen();
    delay(250);
  }
}

void enterBestWord() {
  findBestWords();
  
  xkp = bestLetters.get(0).x;
  ykp = bestLetters.get(0).y;
  updateCoords();
  robot.mouseMove(round(sx + tileSize / 2), round(sy + tileSize / 2));
  delay(150);
  robot.mousePress(InputEvent.BUTTON1_DOWN_MASK);
  delay(150);
  for(int i = 1; i < bestLetters.size(); i++) {
    xkp = bestLetters.get(i).x;
    ykp = bestLetters.get(i).y;
    updateCoords();
    robot.mouseMove(round(sx + tileSize / 2), round(sy + tileSize / 2));    
    delay(100);
  }
  robot.mouseRelease(InputEvent.BUTTON1_DOWN_MASK);
  delay(100);
  robot.mouseMove(0, 0);
  delay(100);
  robot.mousePress(InputEvent.BUTTON1_DOWN_MASK);
  delay(100);
  robot.mouseRelease(InputEvent.BUTTON1_DOWN_MASK);
  
  submitBestWord();  
  setBlankBoard();
  
  //if(word >= 20) {
  //  setBlankBoard();
  //  word = 0;
  //}
  //word++;
}

boolean blankOnBoard() {
  for(int x = 0; x < size - (PCVersion ? 1 : 0); x++) {
    for(int y = 0; y < size - (x % 2 == 0 && PCVersion ? 1 : 0); y++) {
      if(letters[x][y].getLetter().equals("")) return true;    
    }
  }
  return false;
}

void nextLetter() {
  findNextBlank();
  updateCoords();
  
  updateScreen();
  
  findLetter();
  matchLetter();
}

void mousePressed() {
  int x = mouseX / letterSize;
  int y = mouseY / letterSize;
  if(x % 2 == (PCVersion ? 0 : 1)) y = (mouseY - letterSize / 2) / letterSize;
  if(mouseButton == LEFT) {
    if(x >= 0 && x < size - (PCVersion ? 1 : 0) && y >= 0 && y < size - (x % 2 == 0 && PCVersion ? 1 : 0)) {
      switch(letters[x][y].tier) {
        case NOTHING:
          letters[x][y].tier = RewardTier.GREEN;
        break;
        case GREEN:
          letters[x][y].tier = RewardTier.GOLD;
        break;
        case GOLD:
          letters[x][y].tier = RewardTier.SAPPHIRE;
        break;
        case SAPPHIRE:
          letters[x][y].tier = RewardTier.DIAMOND;
        break;
        case DIAMOND:
          if(forced.contains(letters[x][y])) {
            letters[x][y].tier = RewardTier.NOTHING;
            forced.remove(letters[x][y]);  
          }
          else {
            forced.add(letters[x][y]);
          }
        break;
      }
    }
  }
  else {
    if(forcedOut.contains(letters[x][y])) {
      forcedOut.remove(letters[x][y]);  
    }
    else {
      forcedOut.add(letters[x][y]);
    }
  }
  findBestWords();
}
  
void checkForFall() {
  boolean fall = false;
  for(int x = 0; x < size - (PCVersion ? 1 : 0); x++) {
    for(int y = 0; y < size - 1 - (x % 2 == 0 && PCVersion ? 1 : 0); y++) {
      if((!letters[x][y].getLetter().equals("") && letters[x][y + 1].getLetter().equals("") || letters[x][y].burning)) {
        if(forcedOut.contains(letters[x][y])) {
          forcedOut.add(letters[x][y + 1]);  
          forcedOut.remove(letters[x][y]);
        }
        letters[x][y + 1].setLetter(letters[x][y].getLetter());
        letters[x][y + 1].tier = letters[x][y].tier;
        letters[x][y + 1].burning = letters[x][y].burning;
        letters[x][y].setLetter("");
        letters[x][y].tier = RewardTier.NOTHING;
        letters[x][y].burning = false;
        fall = true;
      }
    }
  }
  if(fall) checkForFall();  
}

void submitBestWord() {
  for(Letter letter : bestLetters) {
    if(forced.contains(letter)) {
      forced.remove(letter);  
    }
    letter.tier = RewardTier.NOTHING;
    letter.setLetter("");
  }
  checkForFall(); 
}

void keyPressed() {
  if(key == ENTER) {
    submitBestWord();
    findNextBlank();
  }
  else {
    if(key == CODED) {
      if(keyCode == UP) {
        if(ykp > 0) ykp--;
      }
      else if(keyCode == DOWN) {
        if(ykp < size - 1 - (xkp % 2 == 0 && PCVersion ? 1 : 0)) ykp++;
      }
      else if(keyCode == LEFT) {
        if(xkp > 0) xkp--;
        else if(ykp > 0) {
          xkp = size - 1;
          ykp--;
        }
      }
      else if(keyCode == RIGHT) {
        if(xkp < size - 1 - (PCVersion ? 1 : 0)) xkp++;
        else if(ykp < size - 1 - (xkp % 2 == 0 && PCVersion ? 1 : 0)) {
          xkp = 0;
          ykp++;
        }
      }
    }
    else { 
      letters[xkp][ykp].setLetter("" + key);
      //if(xkp < size - 1) xkp++;
      //else if(ykp < size - 1) {
      //  xkp = 0;
      //  ykp++;
      //}
      findNextBlank();
    }
  }
  
  findBestWords();
}

void findNextBlank() {
  boolean finished = false;
  int oldXkp = xkp;
  int oldYkp = ykp;
  xkp = 0;
  ykp = 0;
  while(!letters[xkp][ykp].getLetter().equals("") && !finished) {
    if(ykp < size - 1 - (xkp % 2 == 0 && PCVersion ? 1 : 0)) ykp++;
    else if(xkp < size - 1 - (PCVersion ? 1 : 0)) {
      ykp = 0;
      xkp++;  
    }
    else {
      finished = true;  
    }
  }
  if(finished) {
    xkp = oldXkp;
    ykp = oldYkp;
    if(ykp < size - 1 - (xkp % 2 == 0 && PCVersion ? 1 : 0)) ykp++;
    else if(xkp < size - 1 - (PCVersion ? 1 : 0)) {
      ykp = 0;
      xkp++;  
    }    
  }
}

int pointsOf(ArrayList<Letter> word) {
  int score = 0;
  int tierPoints = 1;
  for(Letter letter : word) {
    try {
      score += pointTable.get(letter.getLetter());
      
      if(letter.burning) {
        score += 1000 * (letter.y + 1);  
      }
    }
    catch(NullPointerException e) {
      println("NullPointerException");  
    }
    switch(letter.tier) {
      case NOTHING:
        tierPoints += 0;
      break;
      case GREEN:
        tierPoints += 1;
      break;
      case GOLD:
        tierPoints += 2;
      break;
      case SAPPHIRE:
        tierPoints += 3;
      break;
      case DIAMOND:
        tierPoints += 4;
      break;
    }
  }
  score *= tierPoints * 2; // Work out the real tier multiplier later    
  return score;
}

void findBestWords() {
  findBestWord(false);
  findBestWord(true);
}

void findBestWord(boolean mostPoints) { // False means longest word
  if(mostPoints) {
    bestWord = "";
    pointsOfBestWord = 0;
    bestLetters = new ArrayList<Letter>();
  }
  else {
    longestWord = "";
    longestLetters = new ArrayList<Letter>();
  }
  for(int x = 0; x < size; x++) {
    for(int y = 0; y < size; y++) {
      boolean found = false; 
      for(Node node : tree.topNodes) {
        if(node.getLetter().equals(letters[x][y].getLowerLetter()) && !found) {
          investigating = new ArrayList<Letter>();
          investigating.add(letters[x][y]);
          traverse(node, true, mostPoints);
          found = true; 
        }
      }
    }
  }
  
  previousWord = bestWord;
  
  if(mostPoints) println("Best Word: " + bestWord);
  else println("Longest Word: " + longestWord);
}

void traverse(Node node, boolean firstLetter, boolean mostPoints) {
  if(!firstLetter) {
    while(!node.parent.toString().equals(lettersToString(investigating))) {
      investigating.remove(investigating.size() - 1);
    }
    
    boolean found = false;  // Change this system
    for(Letter letter : investigating.get(investigating.size() - 1).getAvailableNeighbours()) {
      if(node.getLetter().equals(letter.getLowerLetter()) && !found) {
        investigating.add(letter);  
        if(node.endNode()) {
          boolean containsForced = true;
          for(Letter forcedLetter : forced) {
            if(!investigating.contains(forcedLetter)) {
              containsForced = false;
            }
          }
          for(Letter forcedLetter : forcedOut) {
            if(investigating.contains(forcedLetter)) {
              containsForced = false;
            }
          }
          if(node.toString().equals(previousWord)) {
            containsForced = false;  
          }
          if(containsForced) {
            if(mostPoints) {
              if(pointsOf(investigating) > pointsOfBestWord) {
                bestLetters = new ArrayList<Letter>();
                bestLetters.addAll(investigating);
                bestWord = node.toString();  
                pointsOfBestWord = pointsOf(investigating);
              }
            }
            else {
              if(node.toString().length() > longestWord.length()) {
                longestLetters = new ArrayList<Letter>();
                longestLetters.addAll(investigating);
                longestWord = node.toString();  
              }
            }
          }
        }
        found = true;
      }
    }
    if(!found) {
      return;  
    }
  }
  
  for(Node child : node.children) {
    traverse(child, false, mostPoints);
  }
}

String lettersToString(ArrayList<Letter> listOfLetters) {
  String str = "";
  for(Letter letter : listOfLetters) {
    str += letter.getLowerLetter();
  }
  return str;
}

enum RewardTier {
  NOTHING,
  GREEN,
  GOLD,
  SAPPHIRE,
  DIAMOND
};

class Letter {
  private String letter;
  boolean burning;
  
  RewardTier tier;
  
  int x;
  int y;
  
  Letter(String letter, int x, int y, RewardTier tier, boolean burning) {
    setLetter(letter);
    this.x = x;
    this.y = y;
    this.tier = tier;
    this.burning = burning;
  }
  
  String getLetter() {
    return letter;
  }
  
  void setLetter(String letter) {
    this.letter = letter.toUpperCase();
    if(this.letter.equals("Q") || this.letter.equals("QU")) {
      this.letter = "Qu";
    }
  }
  
  String getLowerLetter() {
    return letter.toLowerCase();
  }
  
  ArrayList<Letter> getAvailableNeighbours() {
    ArrayList<Letter> neighbours = new ArrayList<Letter>();
    
    if(y + 1 < size) if(!investigating.contains(letters[x][y + 1])) 
      neighbours.add(letters[x][y + 1]);
      
    if(y - 1 >= 0) if(!investigating.contains(letters[x][y - 1])) 
      neighbours.add(letters[x][y - 1]);
      
    if(x + 1 < size) if(!investigating.contains(letters[x + 1][y])) 
      neighbours.add(letters[x + 1][y]);
      
    if(x - 1 >= 0) if(!investigating.contains(letters[x - 1][y])) 
      neighbours.add(letters[x - 1][y]);
      
    if(x % 2 == (PCVersion ? 1 : 0)) {
      if(y - 1 >= 0) {
        if(x + 1 < size) if(!investigating.contains(letters[x + 1][y - 1])) 
          neighbours.add(letters[x + 1][y - 1]);
          
        if(x - 1 >= 0) if(!investigating.contains(letters[x - 1][y - 1])) 
          neighbours.add(letters[x - 1][y - 1]);
      }
    }
    else {
      if(y + 1 < size) {
        if(x + 1 < size) if(!investigating.contains(letters[x + 1][y + 1])) 
          neighbours.add(letters[x + 1][y + 1]);
          
        if(x - 1 >= 0) if(!investigating.contains(letters[x - 1][y + 1])) 
          neighbours.add(letters[x - 1][y + 1]);
      }
    }
    
    return neighbours;
  }
}

String randomLetter() {
  return "" + (char) round(random(65, 90));  
}

class Tree {
  ArrayList<Node> topNodes = new ArrayList<Node>();
  
  Tree() {
      
  }
  
  void fillTree() {
    Node currentNode = null;
    for(String word : words) {
      for(int i = 0; i < word.length(); i++) {
        if(i == 0) {
          if(findNode(topNodes, word.charAt(0)) == null) {       
            topNodes.add(new Node(word.charAt(0) + "", null, false)); // False is put in the for the last parameter as 1 letter words are not allowed  
          }
          currentNode = findNode(topNodes, word.charAt(0)); // This should not be null
        }
        else {
          if(findNode(currentNode.children, word.charAt(i)) == null) {
            currentNode.children.add(new Node(word.charAt(i) + "", currentNode, i == word.length() - 1));
          }
          currentNode = findNode(currentNode.children, word.charAt(i));
        }
      }
    }
    
    // Fix up Q's / Qu's
    ArrayList<Node> badUs = new ArrayList<Node>();
    for(Node node : allNodes) {
      if(node.getLetter().equals("q")) {
        Node U = findNode(node.children, "u");
        if(U == null) continue;
        
        node.setLetter("qu");
        node.endNode = U.endNode();
        for(Node child : U.children) {
          node.children.add(child);
          child.parent = node;
        }
        node.children.remove(U);
        badUs.add(U);
      }
    }
    for(Node U : badUs) {
      allNodes.remove(U);  
    }
  }
}

Node findNode(String str) {
  for(Node node : allNodes) {
    if(node.toString().equals(str)) {
      return node;
    }
  }
  return null;
}

Node findNode(ArrayList<Node> list, char letter) {
  return findNode(list, "" + letter);
}

Node findNode(ArrayList<Node> list, String letter) {
  for(Node node : list) {
    if(node.getLetter().equals(letter)) {
      return node;  
    }
  }
  return null;
}

class Node {
  Node parent;
  ArrayList<Node> children = new ArrayList<Node>();
  
  boolean endNode;
  
  String letter = "";
  
  Node(String letter, Node parent, boolean endNode) {
    this.letter = letter;
    this.parent = parent;
    this.endNode = endNode;
    allNodes.add(this);
  }
  
  @Override
  String toString() {
    return toString(letter, this);
  }
  
  String toString(String str, Node node) {
    if(node.parent == null) {
      return str;
    }
    return toString(node.parent.getLetter() + str, node.parent);
  }
  
  String getLetter() {
    return letter;  
  }
  
  void setLetter(String letter) {
    this.letter = letter;  
  }
  
  boolean endNode() {
    return endNode;
  }
}


//OCR stuff
void updateCoords() {
  sx = isx + tileSize * xkp;
  sy = isy + tileSize * ykp + (xkp % 2 == 0 ? 0 : -tileSize / 2);
  ex = sx + tileSize;
  ey = sy + tileSize;
  
  sx += letterBuffer;
  sy += letterBuffer;
  ex -= letterBuffer;
  ey -= letterBuffer;
}

void findLetter() {
  red = false;
   
  for(int x = round(sx); x <= ex; x++) {
    for(int y = round(sy); y <= ey; y++) {
      Color pixel = new Color(screen.getRGB(x, y));
      
      if(pixel.getRed() > 150 || pixel.getGreen() > 150 || pixel.getBlue() > 150) {
        screen.setRGB(x, y, new Color(255, 255, 255).getRGB()); 
      }
      else {
        screen.setRGB(x, y, new Color(0, 0, 0).getRGB()); 
      }
      
      if(pixel.getRed() > 230 && pixel.getGreen() < 60 && pixel.getBlue() < 60) {
        red = true;  
      }
    }
  }
  
  dotRemover();
  
  int x1 = getLeftmostX(screen, round(sx), round(sy), round(ex), round(ey));
  int y1 = getUpmostY(screen, round(sx), round(sy), round(ex), round(ey));
  int x2 = getRightmostX(screen, round(sx), round(sy), round(ex), round(ey));
  int y2 = getDownmostY(screen, round(sx), round(sy), round(ex), round(ey));
  
  int max = max(x2 - x1, y2 - y1);
  int midX = round((float) (x1 + x2) / 2.0);
  int midY = round((float) (y1 + y2) / 2.0);
  
  x1 = floor(midX - max / 2.0);
  x2 = ceil(midX + max / 2.0);
  y1 = floor(midY - max / 2.0);
  y2 = ceil(midY + max / 2.0);
  
  //x1 = sx;
  //y1 = sy;
  //x2 = ex;
  //y2 = ey;
  
  for(int x = 0; x < res; x++) {
    for(int y = 0; y < res; y++) {
      try {
        Color pixel = new Color(screen.getRGB(round(x1 + (float) x * ((float) (x2 - x1)) / (float) res), round(y1 + (float) y * ((float) (y2 - y1) / (float) res))));
        
        if(pixel.getRed() == 0 && pixel.getGreen() == 0 && pixel.getBlue() == 0) {
          letterMap[x][y] = true; // white
        }
        else {
          letterMap[x][y] = false; // black
        }
      }
      catch(ArrayIndexOutOfBoundsException e) {
        println(e);  
      }
    }
  }  
}

// this is a very primative method, but it is reasonably fast
void dotRemover() {
  bitsChecked= new ArrayList<PVector>();
  for(int x = round(sx); x <= ex; x++) {
    for(int y = round(sy); y <= ey; y++) {
      if(isBlack(x, y)) {
        if(!checked(x, y)) {
          currentDot = new ArrayList<PVector>();
          findDot(x, y);
          if(currentDot.size() <= dotThreshold) {
            removeDot();  
          }
        }
      }
    }
  }
}

boolean checked(int x, int y) {
  for(PVector vector : bitsChecked) {
    if(vector.x == x && vector.y == y) {
      return true;  
    }
  }
  return false;
}

void findDot(int x, int y) {
  currentDot.add(new PVector(x, y));
  bitsChecked.add(new PVector(x, y));
  
  if(x > sx && !checked(x - 1, y)) {
    if(isBlack(x - 1, y)) findDot(x - 1, y);  
  }
  if(x < ex && !checked(x + 1, y)) {
    if(isBlack(x + 1, y)) findDot(x + 1, y);  
  }
  if(y > sy && !checked(x, y - 1)) {
    if(isBlack(x, y - 1)) findDot(x, y - 1);  
  }
  if(y < ey && !checked(x, y + 1)) {
    if(isBlack(x, y + 1)) findDot(x, y + 1);  
  }
}

void removeDot() {
  for(PVector vector : currentDot) {
    screen.setRGB(round(vector.x), round(vector.y), new Color(255, 255, 255).getRGB());     
  }
}

boolean isBlack(int x, int y) {
  Color pixel = new Color(screen.getRGB(x, y));
  return isBlack(pixel);
}

boolean isBlack(Color pixel) {
  return pixel.getRed() == 0 && pixel.getGreen() == 0 && pixel.getBlue() == 0;
}

void updateScreen() {
  Rectangle rectangle = new Rectangle(Toolkit.getDefaultToolkit().getScreenSize());
  screen = robot.createScreenCapture(rectangle);  
  if(screen.getWidth() > 1000) stop();
  checkForLevel();
}

int getLeftmostX(BufferedImage image, int x1, int y1, int x2, int y2) {
  for(int x = x1; x <= x2; x++) {
    for(int y = y1; y <= y2; y++) {
      Color pixel = new Color(image.getRGB(x, y));
      if(pixel.getRed() == 0 && pixel.getGreen() == 0 && pixel.getBlue() == 0) {
        return x;  
      }
    }
  }
  return -1;
}

int getRightmostX(BufferedImage image, int x1, int y1, int x2, int y2) {
  for(int x = x2; x >= x1; x--) {
    for(int y = y1; y <= y2; y++) {
      Color pixel = new Color(image.getRGB(x, y));
      if(pixel.getRed() == 0 && pixel.getGreen() == 0 && pixel.getBlue() == 0) {
        return x;  
      }
    }
  }
  return -1;
}

int getUpmostY(BufferedImage image, int x1, int y1, int x2, int y2) {
  for(int y = y1; y <= y2; y++) {
    for(int x = x1; x <= x2; x++) {
      Color pixel = new Color(image.getRGB(x, y));
      if(pixel.getRed() == 0 && pixel.getGreen() == 0 && pixel.getBlue() == 0) {
        return y;  
      }
    }
  }
  return -1;
}

int getDownmostY(BufferedImage image, int x1, int y1, int x2, int y2) {
  for(int y = y2; y >= y1; y--) {
    for(int x = x1; x <= x2; x++) {
      Color pixel = new Color(image.getRGB(x, y));
      if(pixel.getRed() == 0 && pixel.getGreen() == 0 && pixel.getBlue() == 0) {
        return y;  
      }
    }
  }
  return -1;
}

void matchLetter() {
  int mostMatched = 0;
  TypedLetter mostMatchedLetter = null;
  for(TypedLetter typedLetter : typedLetters) {
    int matched = 0;
    for(int x = 0; x < res; x++) {
      for(int y = 0; y < res; y++) {
        if(letterMap[x][y] == typedLetter.map[x][y]) {
          matched++;  
        }
      }
    }
    if(matched > mostMatched) {
      mostMatched = matched;
      mostMatchedLetter = typedLetter;
    }
    if(mostMatched == res * res) {
      break;  
    }
  }
  
  letters[xkp][ykp].setLetter(mostMatchedLetter.letter);
  letters[xkp][ykp].burning = red; // later make a red tier, for now this will just highly encourage the bot to go for it
}

void fillTypedLetters() {
  String[] maps = loadStrings("Letters.txt");
  for(int i = 0; i < maps.length; i += res + 1) {
    String letter = maps[i];
    boolean[][] tempMap = new boolean[res][res];
    for(int y = i + 1; y < i + 1 + res; y++) {
      for(int x = 0; x < res; x++) {
        tempMap[x][y - i - 1] = (maps[y].charAt(x) + "").equals("1");   
      }
    }
    typedLetters.add(new TypedLetter(letter, tempMap));
  }
}

class TypedLetter {
  String letter;
  boolean[][] map;
  
  TypedLetter(String letter, boolean[][] map) {
    this.letter = letter;
    this.map = map;
  }
}
