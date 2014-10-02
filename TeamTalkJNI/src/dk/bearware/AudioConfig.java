/*
 * Copyright (c) 2005-2014, BearWare.dk
 * 
 * Contact Information:
 *
 * Bjoern D. Rasmussen
 * Skanderborgvej 40 4-2
 * DK-8000 Aarhus C
 * Denmark
 * Email: contact@bearware.dk
 * Phone: +45 20 20 54 59
 * Web: http://www.bearware.dk
 *
 * This source code is part of the TeamTalk 5 SDK owned by
 * BearWare.dk. All copyright statements may not be removed 
 * or altered from any source distribution. If you use this
 * software in a product, an acknowledgment in the product 
 * documentation is required.
 *
 */

package dk.bearware;

public class AudioConfig
{
    public boolean bEnableAGC;
    public int nGainLevel;
    public int nMaxIncDBSec;
    public int nMaxDecDBSec;
    public int nMaxGainDB;
    public boolean bEnableDenoise;
    public int nMaxNoiseSuppressDB;
    public boolean bEnableEchoCancellation;
    public int nEchoSuppress;
    public int nEchoSuppressActive;

    public AudioConfig() {
        bEnableAGC = false;
        nGainLevel = 16000;
        nMaxIncDBSec = 12;
        nMaxDecDBSec = -40;
        nMaxGainDB = 30;
        bEnableDenoise = false;
        nMaxNoiseSuppressDB = -30;
        bEnableEchoCancellation = false;
        nEchoSuppress = -40;
        nEchoSuppressActive = -15;
    }
}