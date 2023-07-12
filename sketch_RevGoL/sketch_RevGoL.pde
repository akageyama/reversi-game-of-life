// RevGoL: Reversi Game of Life
//     by Akira Kageyama, Kobe Univ., Japan (kage@port.kobe-u.ac.jp, sgks@mac.com)
//     on 2018.04.09
// 
// A Game of Life by Processing
//   - Torus geometry, i.e., under the periodic boundary condition.
//   - Reversi-like pieces for alive (black) or dead (white) state of each cell.//
//
// Based on the following example:
//      https://processing.org/examples/gameoflife.html
//      by Joan Soler-Adillon 
//


// Size of cells
int cellSize = 20;

// Number of cell in x and y
int Nx, Ny;


// How likely for a cell to be alive at start (in percentage)
float probabilityOfAliveAtStart = 10;

// Variables for timer
int interval = 200;
int lastRecordedTime = 0;


// Array of cells
int[][] cells; 
// Buffer to record the state of the cells and use this while changing the others in the interations
int[][] cellsCarbonCopy; 

// Pause
boolean pause = false;



void setup() {
  // size (640, 360);
  size (800, 800);
  Nx = width / cellSize;
  Ny = height / cellSize;
  println("Nx, Ny = ", Nx, Ny);
  println("Space=>stop/start. 'c'=>clear, 'r'=>random, Return=>one step, Mouse click=>cell reversal.");

  cells = new int[Nx][Ny];
  cellsCarbonCopy = new int[Nx][Ny];

  // No stroke around each circle.
  noStroke();

  // Anti-aliasing  
  smooth(8);

  // Initialization
  for (int i=1; i<Nx-1; i++) {
    for (int j=1; j<Ny-1; j++) {
      float state = random (100);
      if (state > probabilityOfAliveAtStart) { 
        state = 0;
      } else {
        state = 1;
      }
      cells[i][j] = int(state); // Save state of each cell
    }
  }

  boundaryCondition();
  copyCells();

  //background(210, 220, 250);
}


void place_alive_piece(int i, int j) {
  fill(255, 255, 255); 
  ellipse(i*cellSize+0.51*cellSize, j*cellSize+0.6*cellSize, 
    0.84*cellSize, 0.6*cellSize);
  // fill(220, 40, 40); // red piece 
  fill(0); // black
  ellipse(i*cellSize+0.5*cellSize, j*cellSize+0.5*cellSize, 
    0.84*cellSize, 0.6*cellSize);
}


void place_dead_piece(int i, int j) {
  // fill(200, 100, 150); //pink
  fill(100); // gray
  ellipse(i*cellSize+0.51*cellSize, j*cellSize+0.6*cellSize, 
    0.84*cellSize, 0.6*cellSize);
  fill(255); 
  ellipse(i*cellSize+0.5*cellSize, j*cellSize+0.5*cellSize, 
    0.84*cellSize, 0.6*cellSize);
}


void place_pieces() {
  for (int i=0; i<Nx; i++) {
    for (int j=0; j<Ny; j++) {
      if (cells[i][j]==1) {
        place_alive_piece(i, j);
      } else {
        place_dead_piece(i, j);
      }
    }
  }
}


void draw() {

  background(210, 230, 255);

  place_pieces();

  if (millis()-lastRecordedTime>interval) {
    if (!pause) {
      stepTime();
      lastRecordedTime = millis();
    }
  }

  if (pause && mousePressed) {
    int xCellOver = int(map(mouseX, 0, width, 0, Nx));
    xCellOver = constrain(xCellOver, 0, Nx-1);
    int yCellOver = int(map(mouseY, 0, height, 0, Ny));
    yCellOver = constrain(yCellOver, 0, Ny-1-1);

    if (cellsCarbonCopy[xCellOver][yCellOver]==1) { // alive
      cells[xCellOver][yCellOver]=0; // Kill
    } else { // dead
      cells[xCellOver][yCellOver]=1; // Make alive
    }
  } else if (pause && !mousePressed) { 
    boundaryCondition();
    copyCells();
  }
}



void stepTime() {  
  for (int i=1; i<Nx-1; i++) {
    for (int j=1; j<Ny-1; j++) {
      int neighbours = 0; // Number of alive neighboours.
      for (int ii=i-1; ii<=i+1; ii++) {
        for (int jj=j-1; jj<=j+1; jj++) {  
          if ((ii==i)&&(jj==j)) continue;
          if (cellsCarbonCopy[ii][jj]==1) {
            neighbours ++;
          }
        }
      }
      if (cellsCarbonCopy[i][j]==1) { // The cell is alive.
        if (neighbours < 2 || neighbours > 3) {
          cells[i][j] = 0; // Die unless it has 2 or 3 neighbours
        }
      } else { // The cell is dead.      
        if (neighbours == 3 ) {
          cells[i][j] = 1; // Only if it has 3 neighbours
        }
      }
    }
  }

  boundaryCondition();
  copyCells();
}

void keyPressed() {
  if (key=='r' || key == 'R') {
    // Restart: reinitialization of cells
    for (int i=1; i<Nx-1; i++) {
      for (int j=0; j<Ny-1; j++) {
        float state = random (100);
        if (state > probabilityOfAliveAtStart) {
          state = 0;
        } else {
          state = 1;
        }
        cells[i][j] = int(state); // Save state of each cell
      }
    }
    boundaryCondition();
    copyCells();
  }
  if (key==' ') { // On/off of pause
    pause = !pause;
  }
  if (key=='c' || key == 'C') { // Clear all
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        cells[x][y] = 0; // Save all to zero
      }
    }
  }
  if (key=='\n') {
    stepTime();
  }
}


void boundaryCondition() {
  //
  // When Nx = 10
  //
  //       0    1    2    3    4    5    6    7    8    9
  //       o----o----o----o----o----o----o----o----o----o
  //       |    |                                  |    |
  //   ----o----o                                  o----o----
  //       8    9                                  0    1
  for (int j=1; j<Ny; j++) {
    cells[   0][j] = cells[Nx-2][j];
    cells[Nx-1][j] = cells[   1][j];
  }
  for (int i=0; i<Nx; i++) {
    cells[i][   0] = cells[i][Ny-2];
    cells[i][Ny-1] = cells[i][   1];
  }
}


void copyCells() {
  for (int i=0; i<Nx; i++) {
    for (int j=0; j<Ny; j++) {
      cellsCarbonCopy[i][j] = cells[i][j];
    }
  }
}
