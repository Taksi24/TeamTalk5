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

package dk.bearware.gui;

import dk.bearware.BannedUser;
import dk.bearware.Channel;
import dk.bearware.ClientErrorMsg;
import dk.bearware.RemoteFile;
import dk.bearware.ServerProperties;
import dk.bearware.TeamTalkBase;
import dk.bearware.TextMessage;
import dk.bearware.TextMsgType;
import dk.bearware.User;
import dk.bearware.UserAccount;
import dk.bearware.backend.TeamTalkConnection;
import dk.bearware.backend.TeamTalkConnectionListener;
import dk.bearware.backend.TeamTalkService;
import dk.bearware.data.MyTextMessage;
import dk.bearware.data.TextMessageAdapter;
import dk.bearware.events.CommandListener;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

public class TextMessageActivity
extends Activity implements TeamTalkConnectionListener, CommandListener {

    public static final String TAG = "bearware";
    
    public static final String EXTRA_USERID = "userid";
    
    TeamTalkConnection mConnection;
    TeamTalkService ttservice;
    TextMessageAdapter adapter;
    AccessibilityAssistant accessibilityAssistant;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        setContentView(R.layout.activity_text_message);
        getActionBar().setDisplayHomeAsUpEnabled(true);

        accessibilityAssistant = new AccessibilityAssistant(this);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.text_message, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if(id == R.id.action_settings) {
            return true;
        }
        else if (id == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onStart() {
        super.onStart();        
        
        // Bind to LocalService
        Intent intent = new Intent(getApplicationContext(), TeamTalkService.class);
        mConnection = new TeamTalkConnection(this);
        if(!bindService(intent, mConnection, Context.BIND_AUTO_CREATE))
            Log.e(TAG, "Failed to bind to TeamTalk service");
        else
            mConnection.setBound(true);
    }

    @Override
    protected void onStop() {
        super.onStop();
        
        if(ttservice != null) {
            ttservice.unregisterCommandListener(this);
        }
        
        // Unbind from the service
        if(mConnection.isBound()) {
            unbindService(mConnection);
            mConnection.setBound(false);
        }
    }

    @Override
    public void onServiceConnected(TeamTalkService service) {
        ttservice = service;
        
        final int userid = this.getIntent().getExtras().getInt(EXTRA_USERID);
        final TeamTalkBase ttclient = service.getTTInstance();
        adapter = new TextMessageAdapter(this.getBaseContext(), accessibilityAssistant,
                                         service.getUserTextMsgs(userid),
                                         ttclient.getMyUserID());
        
        ListView lv = (ListView) findViewById(R.id.user_im_listview);
        lv.setTranscriptMode(ListView.TRANSCRIPT_MODE_ALWAYS_SCROLL);
        lv.setAdapter(adapter);
        adapter.notifyDataSetChanged();
        
        Button send_btn = (Button)this.findViewById(R.id.user_im_sendbtn);
        final EditText send_msg = (EditText)this.findViewById(R.id.user_im_edittext);
        send_btn.setOnClickListener(new OnClickListener() {
            
            @Override
            public void onClick(View v) {
                String newmsg = send_msg.getText().toString();
                if(newmsg.isEmpty())
                    return;
                
                User myself = ttservice.getUsers().get(ttclient.getMyUserID());
                MyTextMessage textmsg = new MyTextMessage(myself == null? "" : myself.szNickname);
                textmsg.nMsgType = TextMsgType.MSGTYPE_USER;
                textmsg.nChannelID = 0;
                textmsg.nFromUserID = ttclient.getMyUserID();
                textmsg.nToUserID = userid;
                textmsg.szMessage = newmsg;
                int cmdid = ttclient.doTextMessage(textmsg);
                if(cmdid>0) {
                    ttservice.getUserTextMsgs(userid).add(textmsg);
                    send_msg.setText("");
                    adapter.notifyDataSetChanged();
                }
                else {
                    Toast.makeText(TextMessageActivity.this,
                                   R.string.err_send_text_message,
                                   Toast.LENGTH_LONG).show();
                }
            }
        });
        
        service.registerCommandListener(this);
        
        updateTitle();
    }
    
    void updateTitle() {
        String title = getResources().getString(R.string.title_activity_text_message);
        int userid = this.getIntent().getExtras().getInt(EXTRA_USERID);
        
        User user = ttservice.getUsers().get(userid);
        if(user != null) {
            setTitle(title + " - " + user.szNickname);
        }
    }

    @Override
    public void onServiceDisconnected(TeamTalkService service) {
    }

    @Override
    public void onCmdError(int cmdId, ClientErrorMsg errmsg) {
    }

    @Override
    public void onCmdSuccess(int cmdId) {
    }

    @Override
    public void onCmdProcessing(int cmdId, boolean complete) {
    }

    @Override
    public void onCmdMyselfLoggedIn(int my_userid, UserAccount useraccount) {
    }

    @Override
    public void onCmdMyselfLoggedOut() {
    }

    @Override
    public void onCmdMyselfKickedFromChannel() {
    }

    @Override
    public void onCmdMyselfKickedFromChannel(User kicker) {
    }

    @Override
    public void onCmdUserLoggedIn(User user) {
    }

    @Override
    public void onCmdUserLoggedOut(User user) {
    }

    @Override
    public void onCmdUserUpdate(User user) {
        updateTitle();
    }

    @Override
    public void onCmdUserJoinedChannel(User user) {
    }

    @Override
    public void onCmdUserLeftChannel(int channelid, User user) {
    }

    @Override
    public void onCmdUserTextMessage(TextMessage textmessage) {
        int userid = this.getIntent().getExtras().getInt(EXTRA_USERID);
        if(adapter != null && textmessage.nFromUserID == userid &&
           textmessage.nMsgType == TextMsgType.MSGTYPE_USER) {
            accessibilityAssistant.lockEvents();
            adapter.notifyDataSetChanged();
            accessibilityAssistant.unlockEvents();
        }
    }

    @Override
    public void onCmdChannelNew(Channel channel) {
    }

    @Override
    public void onCmdChannelUpdate(Channel channel) {
    }

    @Override
    public void onCmdChannelRemove(Channel channel) {
    }

    @Override
    public void onCmdServerUpdate(ServerProperties serverproperties) {
    }

    @Override
    public void onCmdFileNew(RemoteFile remotefile) {
    }

    @Override
    public void onCmdFileRemove(RemoteFile remotefile) {
    }

    @Override
    public void onCmdUserAccount(UserAccount useraccount) {
    }

    @Override
    public void onCmdBannedUser(BannedUser banneduser) {
    }
}
