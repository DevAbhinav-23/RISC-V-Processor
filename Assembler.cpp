#include <bits/stdc++.h>

using namespace std;

struct InstrInfo {
    uint32_t opcode;
    uint32_t funct3;
    uint32_t funct7;
    char type; // R, I, L, S, B
};

/* ---------------- Instruction Table ---------------- */

unordered_map<string, InstrInfo> table = {
    // R-type
    {"add",  {0x33, 0x0, 0x00, 'R'}},
    {"sub",  {0x33, 0x0, 0x20, 'R'}},
    {"xor",  {0x33, 0x4, 0x00, 'R'}},
    {"or",   {0x33, 0x6, 0x00, 'R'}},
    {"and",  {0x33, 0x7, 0x00, 'R'}},
    {"sll",  {0x33, 0x1, 0x00, 'R'}},
    {"srl",  {0x33, 0x5, 0x00, 'R'}},
    {"sra",  {0x33, 0x5, 0x20, 'R'}},
    {"slt",  {0x33, 0x2, 0x00, 'R'}},
    {"sltu", {0x33, 0x3, 0x00, 'R'}},

    // I-type arithmetic
    {"addi",  {0x13, 0x0, 0x00, 'I'}},
    {"xori",  {0x13, 0x4, 0x00, 'I'}},
    {"ori",   {0x13, 0x6, 0x00, 'I'}},
    {"andi",  {0x13, 0x7, 0x00, 'I'}},
    {"slti",  {0x13, 0x2, 0x00, 'I'}},
    {"sltiu", {0x13, 0x3, 0x00, 'I'}},
    {"slli",  {0x13, 0x1, 0x00, 'I'}},
    {"srli",  {0x13, 0x5, 0x00, 'I'}},
    {"srai",  {0x13, 0x5, 0x20, 'I'}},

    // Load / Store / Branch
    {"ld",  {0x03, 0x3, 0x00, 'L'}},
    {"sd",  {0x23, 0x3, 0x00, 'S'}},
    {"beq", {0x63, 0x0, 0x00, 'B'}}
};

/* ---------------- Helpers ---------------- */

int reg(const string& r) {
    return stoi(r.substr(1)); // xN → N
}

void emit_big_endian(uint32_t inst) {
    for (int i = 3; i >= 0; i--) {
        uint8_t byte = (inst >> (8 * i)) & 0xFF;
        cout << hex << setw(2) << setfill('0') << (int)byte << endl;
    }
}

/* ---------------- Main ---------------- */

int main() {
    string line;

    while (getline(cin, line)) {

        /* Strip inline comments */
        size_t comment_pos = line.find("//");
        if (comment_pos != string::npos)
            line = line.substr(0, comment_pos);

        /* Trim empty lines */
        if (line.find_first_not_of(" \t") == string::npos)
            continue;

        /* Ignore labels (e.g., fib_loop:) */
        if (line.find(':') != string::npos)
            continue;

        /* Normalize delimiters */
        for (char &c : line)
            if (c == ',' || c == '(' || c == ')')
                c = ' ';

        string op, a, b, c;
        stringstream ss(line);
        ss >> op;

        if (table.find(op) == table.end()) {
            cerr << "Unknown instruction: " << op << endl;
            continue;
        }

        InstrInfo info = table[op];
        uint32_t inst = 0;

        /* -------- R-type -------- */
        if (info.type == 'R') {
            ss >> a >> b >> c;
            inst |= info.opcode;
            inst |= reg(a) << 7;
            inst |= info.funct3 << 12;
            inst |= reg(b) << 15;
            inst |= reg(c) << 20;
            inst |= info.funct7 << 25;
        }

        /* -------- I-type -------- */
        else if (info.type == 'I') {
            ss >> a >> b >> c;
            int imm = stoi(c) & 0xFFF;

            inst |= info.opcode;
            inst |= reg(a) << 7;
            inst |= info.funct3 << 12;
            inst |= reg(b) << 15;

            if (op == "slli" || op == "srli" || op == "srai")
                inst |= (info.funct7 << 25) | ((imm & 0x1F) << 20);
            else
                inst |= imm << 20;
        }

        /* -------- Load -------- */
        else if (info.type == 'L') {
            ss >> a >> c >> b;
            int imm = stoi(c) & 0xFFF;

            inst |= info.opcode;
            inst |= reg(a) << 7;
            inst |= info.funct3 << 12;
            inst |= reg(b) << 15;
            inst |= imm << 20;
        }

        /* -------- Store -------- */
        else if (info.type == 'S') {
            ss >> a >> c >> b;
            int imm = stoi(c) & 0xFFF;

            inst |= info.opcode;
            inst |= (imm & 0x1F) << 7;
            inst |= info.funct3 << 12;
            inst |= reg(b) << 15;
            inst |= reg(a) << 20;
            inst |= (imm >> 5) << 25;
        }

        /* -------- Branch (RAW IMM) -------- */
        else if (info.type == 'B') {
            ss >> a >> b >> c;
            int imm = stoi(c);

            inst |= info.opcode;
            inst |= ((imm >> 11) & 0x1) << 7;
            inst |= ((imm >> 1)  & 0xF) << 8;
            inst |= info.funct3 << 12;
            inst |= reg(a) << 15;
            inst |= reg(b) << 20;
            inst |= ((imm >> 5)  & 0x3F) << 25;
            inst |= ((imm >> 12) & 0x1) << 31;
        }

        emit_big_endian(inst);
    }

    return 0;
}